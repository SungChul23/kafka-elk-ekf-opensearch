locals {

  bucket_name         = "${var.project_name}-eb-sf-${data.aws_caller_identity.current.account_id}"
  firehose_log_group  = "/aws/kinesisfirehose/${var.project_name}"
  firehose_log_stream = "S3Delivery"

  # 추가 및 보정
  firehose_name = "${var.project_name}-firehose"
}

# de-ai-22-eb-stepfucnting-pipeline
# de-ai-25-eb-step-pipeline-firehose