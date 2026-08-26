# U4-orchestration-notify — Infrastructure Design

## Cloud Context
| Item | Value |
|---|---|
| Provider | AWS |
| Region | `us-east-1` (var `aws_region`) |
| Environment | `dev` |
| Change type | Delta on existing root stack (U1–U3) |
| IaC | Same `terraform/` root; new `modules/sns` |

## Logical → AWS Resource Map

| Logical component | AWS / repo resources |
|---|---|
| NotifyTopic | `modules/sns`: `aws_sns_topic`; optional `aws_sns_topic_subscription` (email) |
| TopicAccessPolicy | `aws_sns_topic_policy` in `modules/sns` (`publisher_role_arn` = EC2 orchestrator role) |
| OrchestratorPublishGrant | `aws_iam_role_policy` (or attachment) **no root** `main.tf` → role `local.orchestrator_role_name` / ARN; **identity module intocado** |
| Athena (reuse) | Policies Athena já no root; U4 **não** reescreve; só adiciona SNS Publish + `glue:GetTable` se faltar |
| ProviderRuntime | Update `modules/airflow_ec2/files/bootstrap.sh` + S3 object upload; `requirements.txt` no ArtifactStore path documentado |
| VariableBindingTool | `scripts/set-airflow-variables.ps1` / `.sh` (emit commands); consome output `airflow_variables_map` |
| PipelineReliabilityPolicy | Código DAG (não recurso TF) |
| OperatorE2EGuide | README + `docs/lab-guide.md` |
| PipelineApp | `dags/lab_pipeline_e2e.py`; remove `placeholder_smoke.py` |

## Messaging Specification

| Attribute | Value |
|---|---|
| Module | `terraform/modules/sns` |
| Topic name | `{name_prefix}pipeline-status` (ou equivalente) |
| Subscription | Email se `var.sns_notification_email != ""` |
| Topic policy | Allow `sns:Publish` **somente** `publisher_role_arn` (EC2 role) |
| Encryption | Default AWS-managed (sem CMK) |

## IAM Specification (U4 delta)

| Grant | Location | Scope |
|---|---|---|
| `sns:Publish` | Root policy attach | Resource = SNS topic ARN |
| Athena Start/Get/Stop/Results/GetWorkGroup | **Reuse** existing root policies | Already on orchestrator |
| `glue:GetTable` | Root policy add **if missing** | Glue DB / catalog resources do lab |
| Identity module | **No change** | `airflow_ec2_identity` untouched |

## Compute / Storage (ProviderRuntime)

| Item | Spec |
|---|---|
| New EC2 / containers | None |
| Bootstrap | `pip install -r requirements.txt` no volume compartilhado antes/junto do compose up |
| requirements source | Repo root `requirements.txt` uploaded/synced to ArtifactStore (path in deployment doc) |
| Network change | None (no new VPC endpoints) |

## Monitoring Specification

| Item | Spec |
|---|---|
| New CW alarms | None |
| Pipeline notify | SNS via DAG success + failure callback |
| U1 status-check alarm | Unchanged; **no** SNS action |

## Variables / Outputs

| Name | Type | Notes |
|---|---|---|
| `sns_notification_email` | var string default `""` | Optional subscription |
| `sns_topic_arn` | output | |
| `sns_topic_name` | output | |
| `airflow_variables_map` | output object/map | Keys alinhadas ao FD (`lab_*`) para o helper script |
| Existing U2/U3/orchestrator outputs | keep | Consumed by map / docs |

## Decisions locked (from Infra Q&A)
| Q | Decision |
|---|---|
| 1 | Same root stack |
| 2 | Full `modules/sns` |
| 3 | U4 IAM policies in **root** |
| 4 | Reuse Athena IAM; add SNS (+ GetTable if needed) |
| 5 | Bootstrap pip + requirements on S3 |
| 6 | No network changes |
| 7 | No new alarms / no U1→SNS wire |
| 8 | SNS outputs + `airflow_variables_map` |
| 9 | Update shared-infrastructure.md |
