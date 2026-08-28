# Firehose -> OpenSearch 전달 오류를 확인하기 위한 CloudWatch Logs
resource "aws_cloudwatch_log_group" "firehose" {
  name              = local.firehose_log_group
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = local.firehose_log_stream
  log_group_name = aws_cloudwatch_log_group.firehose.name
}