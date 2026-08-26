# U1-orchestrator-ec2 — Infrastructure Design

## Cloud Context
| Item | Value |
|---|---|
| Provider | AWS |
| Region | Variable `aws_region` (default `us-east-1`) |
| Environment | `dev` |
| Change type | Delta on existing U1 stack |
| Default orchestrator | EC2 + Docker Compose (`orchestrator_mode=ec2`) |
| IaC | Terraform root + new modules |

## Logical → AWS Resource Map

| Logical component | AWS resources (Terraform) |
|---|---|
| AirflowHost | `aws_instance` t3.medium AL2023; EBS root **30 GiB gp3**; public subnet; IMDSv2 required |
| BootstrapAgent | `user_data` template; `aws_s3_object` compose package; systemd units (in bootstrap script) |
| SecurityBaseline (EC2) | SG in `airflow_ec2`: ingress 8080/`operator_cidr`; egress all; no :22 |
| ExecutionIdentity | **`modules/airflow_ec2_identity`**: IAM role + instance profile + SSM core + orchestrator policies |
| ComposePackage | S3 prefix `airflow-ec2/` on existing ArtifactBucket (`aws_s3_object` from `modules/airflow_ec2/files/`) |
| DagSyncAgent | systemd timer in bootstrap (5 min sync) — not separate TF resource |
| HealthMonitor | `aws_cloudwatch_metric_alarm` StatusCheckFailed (no SNS) |
| OperatorAccess | SSM Session Manager; SSM Parameter placeholder for UI password |
| S3PrivatePath | Reuse existing **S3 Gateway Endpoint** (U1 network) |
| OrchestratorMWAA | Unchanged path when `orchestrator_mode=mwaa` |

## Compute Specification

| Attribute | Value |
|---|---|
| Instance | `aws_instance` |
| Type var | `airflow_instance_type` default `t3.medium` |
| AMI | Amazon Linux 2023 (data source `aws_ami`) |
| Subnet | `module.network.public_subnet_id` |
| Public IP | Dynamic (no EIP) |
| Root volume | 30 GiB gp3 explicit |
| Metadata | `http_tokens = required`, hop limit default |
| Tags | Project, Environment, ManagedBy, **CostCenter=lab** |

## Network Specification

| Resource | Spec |
|---|---|
| Placement | Public subnet (existing) |
| SG module | `modules/airflow_ec2` (self-contained) |
| Ingress | TCP 8080 from `var.operator_cidr` only |
| Egress | All (lab; API/S3/Docker pull) |
| SSH | **None** (SSM only) |
| S3 traffic | Via IGW or existing gateway endpoint routes on public RT |

## Storage Specification

| Store | Spec |
|---|---|
| Artifact S3 | Existing bucket; new prefix `airflow-ec2/*` |
| Compose files | Source: `terraform/modules/airflow_ec2/files/` |
| DAGs | Existing `dags/` prefix; sync via DagSyncAgent + `sync-dags.sh` |
| Airflow metadata | Docker volume on root EBS (Postgres container) |

## IAM Specification (EC2 mode)

**Module**: `modules/airflow_ec2_identity`

| Policy area | Scope |
|---|---|
| SSM | `AmazonSSMManagedInstanceCore` |
| SSM Parameter | `ssm:PutParameter`, `GetParameter` on `/{name_prefix}airflow/ui-password` |
| S3 artifacts | Get/List on bucket + `airflow-ec2/` + `dags/` |
| Lake/compute | Reuse/wire existing `mwaa_lake_access` + `mwaa_compute_access` document patterns → attach to **EC2 role** when mode=ec2 |
| MWAA role | **Not created** when mode=ec2 |

When mode=mwaa: existing `modules/identity` MWAA role path unchanged.

## Monitoring Specification

| Item | Spec |
|---|---|
| Alarm | EC2 StatusCheckFailed ≥ 1 for 2 periods |
| SNS | None (U4) |
| Logs | journald on host (no CW agent) |

## Root Wiring (`orchestrator_mode`)

```hcl
# conceptual
module "airflow_ec2_identity" {
  count  = var.orchestrator_mode == "ec2" ? 1 : 0
  source = "./modules/airflow_ec2_identity"
  ...
}

module "airflow_ec2" {
  count  = var.orchestrator_mode == "ec2" ? 1 : 0
  source = "./modules/airflow_ec2"
  ...
}

module "mwaa" {
  count  = var.orchestrator_mode == "mwaa" ? 1 : 0
  source = "./modules/mwaa"
  ...
}
```

Lake/compute IAM attachments in root `main.tf` target `orchestrator_role_arn` (generic output).

## Module Layout (Code Generation target)

```
terraform/
  variables.tf          # + orchestrator_mode, operator_cidr, airflow_instance_type
  outputs.tf            # + orchestrator_role_arn, airflow_ec2_*
  main.tf                 # conditional modules + IAM wiring
  modules/
    airflow_ec2/
      main.tf             # instance, sg, alarm, s3 objects, ssm param, user_data
      variables.tf
      outputs.tf
      files/              # docker-compose.yml, bootstrap.sh, systemd units
    airflow_ec2_identity/
      main.tf             # role, instance profile, base policies
    network/              # unchanged (reuse public_subnet_id)
    artifact_store/       # unchanged
    identity/             # MWAA path only when mode=mwaa
    mwaa/                 # count gated
scripts/
  airflow-ec2-start.sh
  airflow-ec2-stop.sh
  airflow-ec2-status.sh
```

## Outputs Contract

| Output | When |
|---|---|
| `orchestrator_role_arn` | Always (EC2 or MWAA role) |
| `orchestrator_mode` | Always |
| `airflow_ec2_instance_id` | mode=ec2 |
| `airflow_ec2_public_ip` | mode=ec2 |
| `airflow_ui_url` | mode=ec2 (`http://{ip}:8080`) |
| `airflow_ec2_role_arn` | mode=ec2 |
| `mwaa_*` outputs | mode=mwaa only |

## Out of Scope (this delta)
EIP, ALB, RDS, CW agent, SSM VPC interface endpoint, Celery workers, MWAA when mode=ec2.
