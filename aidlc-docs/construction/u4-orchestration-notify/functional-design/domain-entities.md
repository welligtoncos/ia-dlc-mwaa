# U4-orchestration-notify — Domain Entities

## LabPipelineRun
| Attribute | Type | Notes |
|---|---|---|
| dagId | string | `lab_pipeline_e2e` |
| runId | string | Airflow run id |
| executionDate | timestamp | |
| status | enum | `running` \| `success` \| `failed` |
| triggerType | enum | `manual` \| `scheduled` |
| selectExecuted | bool | |
| selectSkipped | bool | |

## ExecutorTask
| Attribute | Type | Notes |
|---|---|---|
| kind | enum | `lambda` \| `glue` \| `ecs` |
| resourceNameOrArn | string | from ResourceBinding |
| taskId | string | Airflow task_id |
| status | enum | `pending` \| `running` \| `success` \| `failed` |
| externalId | string | invoke/job_run/task arn (optional) |

## AthenaQueryStep
| Attribute | Type | Notes |
|---|---|---|
| stepKind | enum | `show_tables` \| `select` |
| workgroup | string | binding |
| database | string | binding |
| sql | string | |
| queryExecutionId | string | when started |
| required | bool | show=true; select depends on enable flag |

## NotificationEvent
| Attribute | Type | Notes |
|---|---|---|
| topicArn | arn | binding `lab_sns_topic_arn` |
| status | enum | `success` \| `failed` |
| payload | json | success extended / failure + optional UI link |
| publishedAt | timestamp | |

## PipelineSchedulePolicy
| Attribute | Type | Notes |
|---|---|---|
| variableKey | string | `lab_e2e_schedule` |
| value | string \| null | empty → None |
| catchup | bool | always false |

## ResourceBinding
| Attribute | Type | Notes |
|---|---|---|
| key | string | Variable name |
| value | string | name/ARN/CSV as needed |
| source | enum | `airflow_variable` |
| requiredAtRuntime | bool | true for core executors/SNS/SHOW |

### Suggested binding keys
| Key | Maps to |
|---|---|
| `lab_lambda_function_name` | U3 Lambda |
| `lab_glue_job_name` | U3 Glue Job |
| `lab_ecs_cluster` | U3 ECS cluster |
| `lab_ecs_task_definition` | U3 task definition |
| `lab_ecs_subnets` | subnet ids (CSV) |
| `lab_ecs_security_groups` | sg ids (CSV) |
| `lab_athena_workgroup` | U2 workgroup |
| `lab_glue_database` | U2 Glue DB |
| `lab_sns_topic_arn` | U4 SNS topic |
| `lab_athena_output_s3` | Athena results URI (if needed) |
| `lab_e2e_enable_select` | `true`/`false` |
| `lab_e2e_schedule` | cron or empty |
| `lab_airflow_ui_base` | optional UI base URL for failure links |

## Entity relationships

```text
LabPipelineRun
  |-- 1..n ExecutorTask (lambda, then glue+ecs)
  |-- 1..n AthenaQueryStep (show; select optional)
  |-- 0..2 NotificationEvent (success and/or failure)
  |-- uses PipelineSchedulePolicy
  |-- resolves ResourceBinding[*]
```

## Decisions locked (from FD Q&A)

| Topic | Decision |
|---|---|
| Domain model | Explicit entities (Q1=A) |
| SELECT branch | Variable `lab_e2e_enable_select`; hard if on (Q2=C) |
| Parallel failure | Fail run on Glue or ECS fail (Q3=A) |
| Bindings | Airflow Variables (Q4=A) |
| Schedule | Variable-driven (Q5=A) |
| Success payload | Extended JSON (Q6=B) |
| Failure payload | + UI link if base set (Q7=B) |
| Re-trigger | Free / best-effort (Q8=A) |
| Acceptance | SHOW path; SELECT not required (Q9=A) |
