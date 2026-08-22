# Personas

## P1 — Alex Rivera (Platform Engineer)

| Campo | Valor |
|---|---|
| **Papel** | Engenheiro(a) de Plataforma / IaC |
| **Objetivo** | Provisionar a stack Terraform de ponta a ponta com least privilege e validar MWAA + rede |
| **Contexto** | Conta AWS `dev`, região `us-east-1`, state local |
| **Dores** | Quotas MWAA, NAT caro, IAM permissivo demais, state local frágil |
| **Sucesso** | `terraform apply` conclui; UI MWAA pública acessível; política de apply documentada e restrita |

**Histórias relacionadas**: US-01, US-02, US-03, US-04, US-10

---

## P2 — Jordan Lee (Data Engineer)

| Campo | Valor |
|---|---|
| **Papel** | Engenheiro(a) de Dados |
| **Objetivo** | Publicar DAG de exemplo e executar pipeline (Lambda, Glue, ECS) até dados consultáveis |
| **Contexto** | Usa Airflow UI e AWS CLI; não gerencia VPC no dia a dia |
| **Dores** | DAG não aparece no MWAA; jobs falham por IAM; resultados Athena sem path definido |
| **Sucesso** | DAG syncado, run bem-sucedido nos 3 executors, query Athena retorna linhas, SNS notifica |

**Histórias relacionadas**: US-05, US-06, US-07, US-09

---

## P3 — Sam Okonkwo (Security / Governance)

| Campo | Valor |
|---|---|
| **Papel** | Segurança / Governança de dados (aprendizado Lake Formation) |
| **Objetivo** | Validar LF-Tags, permissões fine-grained e ausência de `Action="*"` / AdministratorAccess |
| **Contexto** | PoC de aprendizado; UI MWAA pública aceita como risco consciente |
| **Dores** | Lake Formation mal configurado libera dados demais; roles com wildcards |
| **Sucesso** | Locations registradas, LF-Tags aplicadas, principals com grants mínimos; review IAM ok |

**Histórias relacionadas**: US-08, US-10
