# U1 Foundation — Domain Entities

## PlatformContext
| Attribute | Type | Notes |
|---|---|---|
| project | string | ex. `ia-dlc-mwaa` |
| environment | string | `dev` |
| region | string | `us-east-1` |
| namePrefix | string | `{project}-{environment}-` |
| defaultTags | map | Project, Environment, ManagedBy |

## NetworkCapability
| Attribute | Type | Notes |
|---|---|---|
| vpcId | id | |
| privateSubnetIds | id[2] | 2 AZs |
| publicSubnetId | id | NAT host |
| natGatewayId | id | single NAT |
| mwaaSecurityGroupId | id | |
| cidrBlock | cidr | from vars |

## ArtifactBucket
| Attribute | Type | Notes |
|---|---|---|
| bucketName | string | prefixed |
| bucketArn | arn | |
| versioningEnabled | bool | always true |
| publicAccessBlocked | bool | always true |
| dagsPrefix | string | `dags/` |
| pluginsPrefix | string | `plugins/` |
| requirementsKey | string | `requirements.txt` |

## ExecutionIdentity
| Attribute | Type | Notes |
|---|---|---|
| roleName | string | MWAA execution role |
| roleArn | arn | |
| basePolicies | list | S3 artifacts, logs, (KMS) |
| trustPrincipal | service | `airflow.amazonaws.com` / MWAA service |

## AirflowEnvironment
| Attribute | Type | Notes |
|---|---|---|
| name | string | prefixed |
| environmentClass | enum | `mw1.small` |
| airflowVersion | string | default `2.11.2` |
| webserverAccessMode | enum | `PUBLIC` |
| status | enum | target `AVAILABLE` |
| sourceBucketArn | arn | ArtifactBucket |
| executionRoleArn | arn | ExecutionIdentity |
| subnetIds | id[2] | from Network |
| securityGroupIds | id[] | from Network |
| loggingConfiguration | object | CW enabled |
| webserverUrl | url | output |

## ApplyPrincipalPolicy
| Attribute | Type | Notes |
|---|---|---|
| documentPath | path | `policies/terraform-apply-policy.json` |
| scope | enum | PlatformWide (U1–U4) |
| statements | list | least privilege by service |
| commentsRequired | bool | true |

## Relationships

```
PlatformContext 1--1 NetworkCapability
PlatformContext 1--1 ArtifactBucket
PlatformContext 1--1 ExecutionIdentity
PlatformContext 1--1 AirflowEnvironment
PlatformContext 1--1 ApplyPrincipalPolicy

AirflowEnvironment *--1 NetworkCapability
AirflowEnvironment *--1 ArtifactBucket
AirflowEnvironment *--1 ExecutionIdentity
```

## Invariants
- AirflowEnvironment não existe sem Network + ArtifactBucket + ExecutionIdentity válidos.
- ArtifactBucket nunca é o DataLakeStore (U2).
- ApplyPrincipalPolicy.scope = PlatformWide mesmo quando só U1 está implementado no código.
