# modules/sns — NotifyTopic for pipeline status (U4)

variable "name_prefix" {
  type        = string
  description = "Prefixo de nome dos recursos."
}

variable "topic_name" {
  type        = string
  description = "Nome do tópico SNS."
}

variable "publisher_role_arn" {
  type        = string
  description = "ARN da role do orquestrador autorizada a publicar (topic policy)."
}

variable "notification_email" {
  type        = string
  description = "E-mail para subscription opcional; vazio = sem subscription."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags adicionais."
  default     = {}
}

resource "aws_sns_topic" "pipeline" {
  name = var.topic_name

  tags = merge(var.tags, {
    Name       = var.topic_name
    CostCenter = "lab"
  })
}

# Dual-control: only the orchestrator role may Publish.
data "aws_iam_policy_document" "topic" {
  statement {
    sid    = "AllowOrchestratorPublish"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.publisher_role_arn]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.pipeline.arn]
  }
}

resource "aws_sns_topic_policy" "pipeline" {
  arn    = aws_sns_topic.pipeline.arn
  policy = data.aws_iam_policy_document.topic.json
}

resource "aws_sns_topic_subscription" "email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.pipeline.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

output "topic_arn" {
  value = aws_sns_topic.pipeline.arn
}

output "topic_name" {
  value = aws_sns_topic.pipeline.name
}
