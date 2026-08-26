# Execução de Testes Unitários / Estáticos

Lab PoC: sem suite pytest automatizada. Use checks estáticos abaixo.

## 1. Terraform

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa\terraform
terraform fmt -check -recursive
terraform validate
```

**Esperado:** fmt sem diff; validate Success.

## 2. DAG Python syntax

```powershell
cd D:\projetos-ia-aws\ia-dlc-mwaa
python -m py_compile dags\lab_pipeline_e2e.py
```

**Esperado:** exit 0 (sem output).

## 3. Lambda source (U3)

```powershell
python -m py_compile src\lambda_marker\*.py
```

(Se o path local diferir, ajuste conforme `src/`.)

## 4. Revisar resultados

| Check | Esperado |
|---|---|
| fmt/validate | Pass |
| `lab_pipeline_e2e.py` compile | Pass |
| placeholder_smoke | **Ausente** (removido na U4) |

## Corrigir falhas

1. Ler mensagem de erro  
2. Corrigir HCL/Python  
3. Reexecutar o check até passar  
