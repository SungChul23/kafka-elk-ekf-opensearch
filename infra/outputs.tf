output "firehose_stream_name" {
  description = "Vector의 stream_name으로 사용할 Firehose 이름"
  value       = aws_kinesis_firehose_delivery_stream.opensearch.name
}

output "firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.opensearch.arn
}

output "opensearch_domain_name" {
  value = aws_opensearch_domain.factory.domain_name
}

output "opensearch_endpoint" {
  value = "https://${aws_opensearch_domain.factory.endpoint}"
}

output "opensearch_dashboards_url" {
  value = "https://${aws_opensearch_domain.factory.endpoint}/_dashboards/"
}

output "opensearch_index_name" {
  value = var.opensearch_index_name
}

output "firehose_backup_bucket" {
  value = aws_s3_bucket.firehose_backup.bucket
}

output "firehose_log_group" {
  value = aws_cloudwatch_log_group.firehose.name
}

output "vector_firehose_policy_arn" {
  description = "Vector용 기존 IAM User/Role에 필요하면 연결할 정책 ARN"
  value       = aws_iam_policy.vector_firehose_put.arn
}