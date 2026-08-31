variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트명 / Eventbrdige + Stepfunction"
  type        = string
  default     = "de-ai-22-eb-step-pipeline"
}

# firehose 이름, firhose->opensearch : iam role name
variable "firehose_buffer_size" {
  description = "최대 버퍼 사이즈(MB)"
  type        = number
  default     = 64
}
variable "firehose_buffer_interval" {
  description = "최대 버퍼 시간(s)"
  type        = number
  default     = 300
}

# vector -> firhose : iam role name
variable "vector_iam_user_name" {
  description = "선택값. 로컬 Vector가 사용하는 기존 IAM User에 Firehose Put 권한을 Terraform으로 붙일 때 지정한다. 비워두면 정책만 생성한다."
  type        = string
  default     = ""
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default = {
    Project   = "kafka-local-opensearch"
    ManagedBy = "Terraform"
    Purpose   = "data-engineering-lab"
  }
}