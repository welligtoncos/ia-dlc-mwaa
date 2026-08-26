# Copie para terraform.tfvars (gitignored) ou passe via OPERATOR_CIDR / -var-file.
# No Git Bash (Windows), prefira OPERATOR_CIDR ou tfvars — evita MSYS converter "/32".

orchestrator_mode = "ec2"
operator_cidr     = "179.210.97.168/32"
# Free Tier: t3.small (2GiB) costuma OOM com Airflow; m7i-flex.large (8GiB) é elegível Free Tier.
airflow_instance_type = "m7i-flex.large"
