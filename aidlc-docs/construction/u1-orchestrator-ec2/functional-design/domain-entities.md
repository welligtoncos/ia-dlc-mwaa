# U1-orchestrator-ec2 — Domain Entities

## OrchestratorMode
| Attribute | Type | Notes |
|---|---|---|
| value | enum | `ec2` \| `mwaa` |
| default | enum | `ec2` |

## AirflowHost
| Attribute | Type | Notes |
|---|---|---|
| instanceId | id | EC2 |
| instanceType | string | `t3.medium` |
| amiFamily | string | Amazon Linux 2023 |
| subnetId | id | public |
| securityGroupId | id | 8080/CIDR |
| publicIp | string | dynamic (no EIP) |
| state | enum | pending/running/stopped/... |
| bootstrapStatus | enum | pending/retrying/healthy/failed |

## ComposeStack
| Attribute | Type | Notes |
|---|---|---|
| airflowVersion | string | `2.11.2` |
| executor | string | LocalExecutor |
| services | list | postgres, webserver, scheduler |
| packageS3Uri | uri | ArtifactStore `airflow-ec2/` |
| dagsMountPath | path | local volume |
| uiPort | int | 8080 |

## DagSyncAgent
| Attribute | Type | Notes |
|---|---|---|
| intervalMinutes | int | 5 |
| sourcePrefix | string | `dags/` on ArtifactStore |
| targetPath | path | Compose dags mount |
| lastSyncAt | timestamp | optional ops |

## OperatorAccess
| Attribute | Type | Notes |
|---|---|---|
| operatorCidr | cidr | required var |
| uiUrl | url | `http://{publicIp}:8080` |
| shellMethod | enum | `ssm` only |
| uiPasswordParam | ssm_param | generated at bootstrap |

## ExecutionIdentity
| Attribute | Type | Notes |
|---|---|---|
| roleName | string | `…-airflow-ec2-execution` |
| roleArn | arn | |
| instanceProfileArn | arn | |
| trustPrincipal | service | `ec2.amazonaws.com` |
| ssmCoreAttached | bool | true |
| orchestratorPolicies | list | artifacts + lake/compute |

## ComposePackage
| Attribute | Type | Notes |
|---|---|---|
| bucketName | string | ArtifactStore |
| prefix | string | `airflow-ec2/` |
| objects | list | compose.yml, env templates, bootstrap helpers |

## OrchestratorReadiness
| Attribute | Type | Notes |
|---|---|---|
| hostRunning | bool | |
| composeHealthy | bool | |
| uiReachable | bool | from operator CIDR |
| ssmOk | bool | |
| smokeDagsListed | bool | placeholder DAG visible |

## Relationships

```
OrchestratorMode
    |--ec2--> AirflowHost --runs--> ComposeStack
    |              |--uses--> ExecutionIdentity
    |              |--accessedVia--> OperatorAccess
    |              |--hosts--> DagSyncAgent --reads--> ComposePackage/ArtifactStore dags
    |--mwaa--> (legacy AirflowEnvironment U1)
```
