# U1 Foundation — Business Logic Model

## Purpose
Modelar a lógica de provisionamento da fundação da plataforma (capability Platform), independente de sintaxe Terraform.

## Primary Flow — Provision Foundation

```
1. Define PlatformContext (project, env, region, tags)
2. Provision NetworkCapability
3. Provision ArtifactBucketCapability
4. Provision ExecutionIdentity (MWAA exec role + base policies)
5. Provision AirflowEnvironment (MWAA)
6. Assert EnvironmentReadiness (status AVAILABLE)
7. Publish FoundationOutputs (ids/arns/urls for U2-U4)
```

## Parallelism Rules
- Dentro de U1: ordem **estrita** Network → ArtifactBucket → ExecutionIdentity → MWAA → readiness.
- Artifact upload / DAG sync **fora** deste fluxo (U4 / operação manual).

## Capability Behaviors

### NetworkCapability
- Garante conectividade privada para MWAA + egress via NAT único.
- Produz: vpcId, privateSubnetIds[2], publicSubnetId, mwaaSecurityGroupId.

### ArtifactBucketCapability
- Garante storage versionado e privado para código Airflow.
- Produz: bucketName, bucketArn, dagsPrefix, pluginsPrefix, requirementsKey.
- **Não** escreve objetos de DAG no provisionamento.

### ExecutionIdentity
- Garante principal de execução do MWAA com least privilege **base** (S3 artefatos, logs, KMS se houver).
- Grants para U2/U3 podem ser anexados depois, mas a **policy de apply** já descreve U1–U4.

### AirflowEnvironment
- Materializa o orquestrador managed com classe/versão/access mode acordados.
- Consome Network + ArtifactBucket + ExecutionIdentity.

### ApplyPrincipalPolicy
- Artefato documental/JSON: permissões mínimas do humano/role que executa apply da plataforma inteira.

## Outputs Consumed Downstream
| Output | Consumidores |
|---|---|
| network ids | U3 ECS |
| artifact bucket | U4 sync, MWAA |
| mwaa env / role | U3 grants, U4 runtime |
| naming prefix | all units |

## Error Semantics
- Qualquer falha no fluxo → aborta provisionamento (sem compensação automática).
- Rollback = procedimento operacional documentado (destroy parcial/full).
