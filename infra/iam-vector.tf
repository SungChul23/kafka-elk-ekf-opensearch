# 로컬 Vector가 Firehose에 데이터를 넣기 위한 최소 권한 정책
resource "aws_iam_policy" "vector_firehose_put" {
  name        = "${var.project_name}-vector-put"
  description = "Allow local Vector to put records into the lab Firehose stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch",
          "firehose:DescribeDeliveryStream"
        ]
        # 이름 수정
        Resource = aws_kinesis_firehose_delivery_stream.bronze.arn
      }
    ]
  })
}

# 기존 IAM User 이름을 지정한 경우에만 위 정책을 자동으로 연결한다.
resource "aws_iam_user_policy_attachment" "vector" {
  count = var.vector_iam_user_name == "" ? 0 : 1

  user       = var.vector_iam_user_name
  policy_arn = aws_iam_policy.vector_firehose_put.arn
}