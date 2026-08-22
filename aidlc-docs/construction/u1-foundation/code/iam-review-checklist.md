# IAM Review Checklist (obrigatório antes do apply)

- [ ] Credenciais válidas: `aws sts get-caller-identity`
- [ ] Principal de apply **não** tem `AdministratorAccess` (ou aceite consciente do risco)
- [ ] Policy `policies/terraform-apply-policy.json` revisada (Sids / escopo U1–U4)
- [ ] Nenhuma policy do **stack** (roles MWAA etc.) usa `Action: "*"`
- [ ] Artifact bucket terá BPA + SSE (módulo artifact_store)
- [ ] UI MWAA PUBLIC compreendida como risco de PoC
- [ ] Região/conta corretas (`aws_region` / profile)
- [ ] Quota MWAA disponível na região
- [ ] Backup planejado do state local após apply
- [ ] `terraform plan` revisado antes de `apply`
