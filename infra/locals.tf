locals {
  opensearch_domain_name = "${var.project_name}-os"
  opensearch_domain_arn  = "arn:${data.aws_partition.current.partition}:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${local.opensearch_domain_name}"
  backup_bucket_name     = "${var.project_name}-kafka-${data.aws_caller_identity.current.account_id}"
  firehose_log_group     = "/aws/kinesisfirehose/${var.project_name}"
  firehose_log_stream    = "OpenSearchDelivery"
}