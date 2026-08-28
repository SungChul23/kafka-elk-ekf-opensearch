# vector -> 데이터 put -> Firehose 입력 (direct put firehose)
resource "aws_kinesis_firehose_delivery_stream" "opensearch" {
  name        = var.project_name
  destination = "opensearch"
  opensearch_configuration {
    # opensearch의 arn
    domain_arn = aws_opensearch_domain.factory.arn
    role_arn   = aws_iam_role.firehose.arn
    # 검색엔진의 인덱스 구분정보 문자열 세팅 -> 전송하는 데이터는 특정 인덱스로 관리
    index_name = var.opensearch_index_name
    # 시간 정보를 이용하여 데이터를 나누는 행위 x, 데이터는 통으로 들어감
    index_rotation_period = "NoRotation"
    buffering_size        = var.firehose_buffer_size
    buffering_interval    = var.firehose_buffer_interval
    retry_duration        = 300
    # s3로 백업되는 데이터는 전솔 실패한 데이터만 전송(오픈서치에서는 데이터를 document라 부름)
    s3_backup_mode = "FailedDocumentsOnly"

    s3_configuration {
      role_arn           = aws_iam_role.firehose.arn
      bucket_arn         = aws_s3_bucket.firehose_backup.arn
      prefix             = "failed-documents/"
      buffering_size     = 5
      buffering_interval = 60
      compression_format = "GZIP"
    }
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }
  }
  depends_on = [
    aws_iam_role_policy.firehose
  ]
}