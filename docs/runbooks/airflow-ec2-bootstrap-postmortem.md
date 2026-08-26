# Postmortem — falhas de bootstrap Airflow EC2 (ago/2026)

Documento de referência para **não repetir** os três problemas que impediram a UI Airflow de subir após o apply U4 (substituição da EC2 por drift de AMI).

**Sintoma inicial:** `ui_health: FAIL` em http://&lt;ip&gt;:8080 após `terraform apply`, com `ssm_ping: Online`.

---

## Linha do tempo resumida

| # | Erro observado | Causa raiz | Correção no repo |
|---|---|---|---|
| 1 | `/usr/bin/env: 'bash\r': No such file or directory` | `bootstrap.sh` (e outros arquivos) no S3 com **CRLF** (upload/edition no Windows) | LF + `.gitattributes` + `sed` no `user_data.sh.tpl` |
| 2 | `airflow: command not found` no `airflow db check` | Volume `python-packages` montado em **`/home/airflow/.local`**, ocultando o binário da imagem | Montar em `/opt/airflow/python-packages` + `pip --target` |
| 3 | `airflow webserver has been removed` / webserver em crash loop | `pip install` do provider Amazon puxou **Airflow 3.3.1** para `PYTHONPATH` | Pin `apache-airflow-providers-amazon==8.28.0` + `pip install --no-deps` |
| 4 | `botocore.exceptions.NoRegionError: You must specify a region` | Containers sem `AWS_REGION` / `AWS_DEFAULT_REGION` (instance role sem região implícita) | Compose + `.env` + Variable `lab_aws_region` + `region_name` no DAG |

---

## Incidente 1 — CRLF (`bash\r`)

### Como detectar

```powershell
# Via SSM (user-data ou bootstrap log ausente)
aws ssm start-session --target "$(terraform -chdir=terraform output -raw airflow_ec2_instance_id)"
sudo tail -50 /var/log/user-data.log
# Erro típico: /usr/bin/env: 'bash\r': No such file or directory
```

Ou: `/var/log/airflow-ec2-bootstrap.log` **não existe** porque o script nem chegou a rodar.

### Por que acontece

- Desenvolvimento no **Windows** grava `\r\n` em `.sh`, `.service`, `.timer`.
- O pacote Compose vai para S3 (`terraform/modules/airflow_ec2/files/` → `s3://…/airflow-ec2/`).
- O `user_data` da EC2 baixa e executa `bootstrap.sh` com shebang `#!/usr/bin/env bash` → Linux interpreta `bash\r` como comando inexistente.

### Prevenção (obrigatório)

1. **`.gitattributes`** na raiz do repo (já presente):

   ```gitattributes
   *.sh text eol=lf
   **/airflow_ec2/files/** text eol=lf
   **/airflow_ec2/templates/** text eol=lf
   ```

2. Após editar arquivos em `terraform/modules/airflow_ec2/files/` ou `scripts/*.sh`, **reaplicar Terraform** para atualizar objetos S3 (etag muda):

   ```powershell
   .\scripts\apply.ps1
   ```

3. O `user_data.sh.tpl` agora executa `sed -i 's/\r$//'` nos scripts baixados do S3 (defesa em profundidade no first-boot).

4. **Verificar LF localmente** antes de commit/upload:

   ```powershell
   python -c "p=r'terraform/modules/airflow_ec2/files/bootstrap.sh'; d=open(p,'rb').read(); print('CRLF' if b'\r\n' in d else 'LF OK')"
   ```

5. **Não** usar `aws s3 cp` manual de arquivos editados no Notepad/Windows sem normalizar LF — prefira `terraform apply` ou conversão explícita.

---

## Incidente 2 — volume sobre `/home/airflow/.local`

### Como detectar

Bootstrap avança (Docker sobe), mas falha em:

```text
ERROR! Maximum number of retries (20) reached.
$ airflow db check
/entrypoint: line 20: airflow: command not found
```

### Por que acontece

A imagem `apache/airflow:2.11.2` instala o CLI em paths que incluem `/home/airflow/.local/bin`.  
Montar um volume **vazio** em `/home/airflow/.local` **substitui** esse diretório dentro do container — o binário `airflow` some.

### Prevenção (obrigatório)

- **Nunca** montar pacotes pip extras em `/home/airflow/.local`.
- Padrão adotado no `docker-compose.yml`:

  ```yaml
  volumes:
    - ${AIRFLOW_PROJ_DIR}/python-packages:/opt/airflow/python-packages
  environment:
    PYTHONPATH: /opt/airflow/python-packages
    PATH: /usr/local/bin:/usr/bin:/bin:/home/airflow/.local/bin
  ```

- No `bootstrap.sh`, instalar com:

  ```bash
  pip install --no-cache-dir --no-deps -r /requirements.txt --target /opt/airflow/python-packages
  ```

---

## Incidente 3 — pip puxou Airflow 3.x

### Como detectar

Webserver reinicia em loop. Logs do container:

```text
airflow command error: Command `airflow webserver` has been removed. Please use `airflow api-server`
```

Dentro do scheduler:

```bash
docker exec airflow-ec2-airflow-scheduler-1 airflow version
# 3.3.1   ← ERRADO (imagem é 2.11.2)
```

### Por que acontece

`requirements.txt` com faixa aberta:

```text
apache-airflow-providers-amazon>=9.0.0,<10.0.0
```

O `pip install` **sem** `--no-deps` resolve dependências e instala `apache-airflow==3.3.1` em `/opt/airflow/python-packages`.  
Com `PYTHONPATH` apontando para lá, o CLI 3.x sobrescreve o 2.11.2 da imagem.

### Prevenção (obrigatório)

1. **Pin explícito** compatível com Airflow **2.11.2**:

   ```text
   apache-airflow-providers-amazon==8.28.0
   ```

   (Arquivos: `requirements.txt` na raiz **e** `terraform/modules/airflow_ec2/files/requirements.txt`.)

2. **`pip install --no-deps`** no bootstrap — a imagem já traz Airflow e a maioria das deps.

3. **Nunca** usar faixas abertas (`>=9`) em requirements instalados em runtime sobre imagem pinada 2.11.x.

4. Após mudar `requirements.txt`, sync + re-bootstrap:

   ```powershell
   .\scripts\sync-dags.ps1
   # Se EC2 já estava up: re-run bootstrap (ver recuperação abaixo)
   ```

---

## Procedimento de recuperação manual (SSM)

Use quando `ui_health: FAIL` persistir após apply ou após editar o pacote Compose/requirements **sem** recriar a EC2.

```powershell
$instanceId = terraform -chdir=terraform output -raw airflow_ec2_instance_id
aws ssm start-session --target $instanceId
```

Dentro da sessão:

```bash
export ARTIFACT_BUCKET="$(grep ARTIFACT_BUCKET /etc/airflow-ec2.env | cut -d= -f2)"
export AWS_REGION="$(grep AWS_REGION /etc/airflow-ec2.env | cut -d= -f2)"
export SSM_PASSWORD_PARAM="$(grep SSM_PASSWORD_PARAM /etc/airflow-ec2.env | cut -d= -f2)"
export AIRFLOW_IMAGE_DIGEST="$(grep AIRFLOW_IMAGE_DIGEST /etc/airflow-ec2.env | cut -d= -f2)"

cd /opt/airflow-ec2
sudo docker compose --env-file .env down -v || true
sudo rm -rf /opt/airflow-ec2/python-packages/*

sudo aws s3 sync "s3://${ARTIFACT_BUCKET}/airflow-ec2/" /opt/airflow-ec2/ --region "${AWS_REGION}"
sudo aws s3 cp "s3://${ARTIFACT_BUCKET}/requirements.txt" /opt/airflow-ec2/requirements.txt --region "${AWS_REGION}" || true

for f in /opt/airflow-ec2/*.sh /opt/airflow-ec2/*.service /opt/airflow-ec2/*.timer; do
  [ -f "$f" ] && sudo sed -i 's/\r$//' "$f"
done
sudo chmod +x /opt/airflow-ec2/bootstrap.sh
sudo /opt/airflow-ec2/bootstrap.sh
```

Aguarde **5–15 min** e confirme:

```powershell
.\scripts\airflow-ec2-status.ps1
# ui_health: OK
# airflow version dentro do container deve ser 2.11.2
```

---

## Checklist antes de considerar o lab “pronto”

- [ ] `.\scripts\airflow-ec2-status.ps1` → `ui_health: OK`
- [ ] `docker exec … airflow version` → **2.11.2** (não 3.x)
- [ ] `operator_cidr` no `terraform.tfvars` = seu IP público `/32` atual
- [ ] `.\scripts\sync-dags.ps1` executado
- [ ] (U4) `.\scripts\set-airflow-variables.ps1` + variables no scheduler
- [ ] Arquivos `*.sh` e `airflow_ec2/files/*` commitados com **LF** (Git respeita `.gitattributes`)

---

## Outros cuidados relacionados

### EC2 substituída no apply (drift de AMI)

Se `terraform apply` **replace** a instância (`ami` mudou), espere bootstrap completo de novo.  
O módulo `airflow_ec2` usa `lifecycle { ignore_changes = [ami] }` para evitar replace acidental — reaplique para persistir.

### IP público e Security Group

`ui_health: FAIL` também ocorre se `operator_cidr` não inclui seu IP atual (VPN, rede nova).  
Atualize `terraform.tfvars` e `.\scripts\apply.ps1`.

### Onde estão os arquivos críticos

| Arquivo | Função |
|---|---|
| `terraform/modules/airflow_ec2/files/bootstrap.sh` | First-boot: Docker, pip, Compose |
| `terraform/modules/airflow_ec2/files/docker-compose.yml` | Stack Airflow + volumes |
| `terraform/modules/airflow_ec2/files/requirements.txt` | Provider Amazon (pin 8.28.0) |
| `terraform/modules/airflow_ec2/templates/user_data.sh.tpl` | cloud-init + strip CRLF |
| `requirements.txt` (raiz) | Sync via `sync-dags.ps1` → bucket |
| `.gitattributes` | Força LF no git checkout |

---

## Referências

- Guia operacional: [`docs/lab-guide.md`](../lab-guide.md) — §8 Troubleshooting
- Script de status: `scripts/airflow-ec2-status.ps1`
- Logs: `/var/log/user-data.log`, `/var/log/airflow-ec2-bootstrap.log` (SSM)
