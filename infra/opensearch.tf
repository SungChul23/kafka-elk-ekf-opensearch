data "aws_iam_policy_document" "opensearch_access" {
  statement {
    sid    = "AllowFirehoseDelivery"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose.arn]
    }
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]
    resources = ["${local.opensearch_domain_arn}/*"]
  }
  statement {
    sid    = "AllowDashboardFromMyIp"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["es:ESHttp*"]
    resources = ["${local.opensearch_domain_arn}/*"]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [var.allowed_cidr]
    }
  }
}
resource "aws_opensearch_domain" "factory" {
  domain_name    = local.opensearch_domain_name
  engine_version = var.opensearch_engine_version

  cluster_config {
    instance_type          = var.opensearch_instance_type
    instance_count         = 1
    zone_awareness_enabled = false
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.opensearch_ebs_volume_size
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  access_policies = data.aws_iam_policy_document.opensearch_access.json

  provisioner "local-exec" {
    command = <<-EOT
      curl -X PUT "https://${self.endpoint}/factory-sensor" \
        -H "Content-Type: application/json" \
        -d '{"mappings":{"properties":{"@timestamp":{"type":"date_nanos"},"timestamp":{"type":"date"},"vector_ingest_at":{"type":"date_nanos"},"sensor_id":{"type":"keyword"},"temperature":{"type":"float"},"humidity":{"type":"float"},"status":{"type":"keyword"}}}}'
    EOT
  }
}