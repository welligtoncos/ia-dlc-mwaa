# Política IAM do principal que executa `terraform apply`

Arquivo: `terraform-apply-policy.json`

## Por que existe
O operador/role de apply precisa criar o stack **inteiro** (U1–U4) sem `AdministratorAccess`.
Esta policy é um **ponto de partida least-privilege relativo** para PoC: ações nomeadas por serviço, sem `Action: "*"`.

## Avisos
- Vários statements usam `Resource: "*"` porque APIs EC2/IAM/S3 de create frequentemente exigem isso; **não** é o mesmo que `Action: "*"`.
- Antes do apply em conta compartilhada, rode o [IAM review checklist](../aidlc-docs/construction/u1-foundation/code/iam-review-checklist.md).
- Ajuste ARNs quando endurecer para produção (escopo por prefixo `ia-dlc-mwaa-dev-*`).

## Sid → motivo
| Sid | Motivo |
|---|---|
| TerraformStateLocalOnlyNote | Validar identidade CLI |
| VpcNetworkingEc2 | U1 rede + VPC endpoint S3 |
| IamRolesPoliciesForStack | Roles MWAA/Lambda/Glue/ECS |
| S3BucketsPlatform | Artifact + data lake futuros |
| MwaaFullManage | Ambiente MWAA |
| LogsForMwaa | Log groups |
| FutureU2... | Glue/LF/Athena (U2) |
| FutureU3... | Lambda/ECS (U3) |
| FutureU4Sns | SNS (U4) |

## Como anexar
```bash
aws iam put-user-policy \
  --user-name SEU_USER \
  --policy-name ia-dlc-mwaa-terraform-apply \
  --policy-document file://policies/terraform-apply-policy.json
```
(ou equivalente em role/permission set SSO)
