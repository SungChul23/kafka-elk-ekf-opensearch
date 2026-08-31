# vector -> 데이터 put -> Firehose 입력 (direct put firehose)
resource "aws_kinesis_firehose_delivery_stream" "bronze" {
  name = local.firehose_name
  # 목적지 수정
  destination = "extended_s3"
  # 목적지 구성
  extended_s3_configuration {
    # role
    role_arn = aws_iam_role.firehose.arn
    # 버킷
    bucket_arn = aws_s3_bucket.data_lake.arn
    # 버퍼크기
    buffering_size = var.firehose_buffer_size
    # 버퍼인터벌
    buffering_interval = var.firehose_buffer_interval
    # 압축형태
    compression_format = "GZIP"
    # 서울 시간대 조정
    custom_time_zone = "Asia/Seoul"
    # 프리픽스
    prefix = "bronze/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    # 에러프리픽스
    error_output_prefix = "firehose-error/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    # 로그->클라우드와치
    cloudwatch_logging_options {
      enabled = true
      # 이름 보정
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }
  }


  depends_on = [
    aws_iam_role_policy.firehose
  ]
}