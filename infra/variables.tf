variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트명"
  type        = string
  default     = "de-ai-22-kafka-efk"
}
# opensearch 서비스(<-엘라스틱서치)/ opensearch 대시보드(<-키바나) 접속 가능한 IP 입력
variable "allowed_cidr" {
  description = "opensearch 대시보드/API에 접속한 공인 IP x.x.x.x/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_cidr, 0))
    error_message = "가능한 주소는 CIDR 형식이여야 합니다."
  }
}

variable "opensearch_engine_version" {
  description = "OpenSearch 엔진 버전"
  type        = string
  default     = "OpenSearch_3.5"
}

variable "opensearch_instance_type" {
  description = "학습용 OpenSearch 데이터 노드 인스턴스"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_ebs_volume_size" {
  description = "OpenSearch EBS 볼륨 크기(GB)"
  type        = number
  default     = 10
}
# opensearch, spec(버전, 인스턴유형, 볼륨단위, 인덱스등 설정)
variable "opensearch_index_name" {
  description = "firehose가 데이터를 opensearch에 적재할때 세팅하는 인덱스값"
  type        = string
  default     = "factory-sensor-001"
}

# firehose 이름, firhose->opensearch : iam role name
variable "firehose_buffer_size" {
  description = "오픈 서치로 전송할때 최대 버퍼 사이즈(MB)"
  type        = number
  default     = 1
}
variable "firehose_buffer_interval" {
  description = "오픈 서치로 전송할때 최대 버퍼 시간(s)"
  type        = number
  default     = 60
}

# vector -> firhose : iam role name
variable "vector_iam_user_name" {
  description = "선택값. 로컬 Vector가 사용하는 기존 IAM User에 Firehose Put 권한을 Terraform으로 붙일 때 지정한다. 비워두면 정책만 생성한다."
  type        = string
  default     = "de-ai-22-ap2-kafka-vector-user"
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