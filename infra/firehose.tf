# vector -> 데이터 put -> Firehose 입력 (direct put firehose)
resource "aws_kinesis_firehose_delivery_stream" "opensearch" {
  name        = var.project_name
  destination = "opensearch"

  depends_on = [
    aws_iam_role_policy.firehose
  ]
}