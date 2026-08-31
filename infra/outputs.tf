output "firehose_stream_name" {
  description = "Vector의 stream_name으로 사용할 Firehose 이름"
  value       = aws_kinesis_firehose_delivery_stream.bronze.name
}

output "firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.bronze.arn
}

output "firehose_backup_bucket" {
  value = aws_s3_bucket.data_lake.bucket
}

output "firehose_log_group" {
  value = aws_cloudwatch_log_group.firehose.name
}

output "vector_firehose_policy_arn" {
  description = "Vector용 기존 IAM User/Role에 필요하면 연결할 정책 ARN"
  value       = aws_iam_policy.vector_firehose_put.arn
}