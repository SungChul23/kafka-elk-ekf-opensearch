# 목표
- 기존 로그젠 => fluent-bit => kafka => vector => firehose 동일
    - kafka를 굳이 사용하는 이유?
        - 데이터 트레픽이 급상승, 처리량 많아질때 
            - 안정성 제공 (손실 x)
            - 극저 지연 전송
            - 토픽을 구독하는 여러 컨슈머에게 동시 전송 가능함
                - 원소스 멀티유즈 사용 가능
            - ...
- firehose -> s3 bronze 적제 
                -> EventBridge 서비스
                    => 이벤트 버스 + (스케줄)
                        - `이벤트` 트리거 활용 메탈리온 아킥텍처 기반 전처리 수행
                        - Airflow에서는 센서를 이용하여 이벤트 감지 -> task 작동
                    => [v]스케줄
                        - 특정 시간이되면 (매시간 10분에 `스케줄링`) 메탈리온 아킥텍처 기반 전처리 수행
                        - Airflow에서 스케쥴 적용 task 작동
                -> 트리거 작동 -> 실제 작업(task) 진행 : Step Functions
                    => 메탈리온 아킥텍처 기반 전처리 수행 실제 세부 task를 구성 => ... => s3 하위에 silber, gold, 기타 등등 데이터들을 처리하여 세팅 해둠 => 대시보드, 각종 서비스에서 s3를 조회하여(athena)를 활용
                -> glue등 에서 db/table등, job(전처리-pandas, polars, pyspark)을 구성 진행 -> task에 관여, 저장형태(컬럼)

- 요약
    - 배치 프로세싱 기준, 저비용, 고효율 작업 구성
        - EventBridge : 트리거 역활/본 프로젝트는 스케줄만 적용
        - Step Functions : 실제 절차적 task 담당. ETL 수행, 메탈리온 아키텍쳐 처리 task 정의
        - glue : 데이터 구조에 따른 스키마, ETL JOB을 제공(스파크, pandas 활용)
        - 기타 : 권한, 변수, 등등 조정, 추가
        - firehose에서 기존 opensearch(제거)로 가는 방향성, s3로 변경

# 데이터 파이프라인
```
================================================================================
데이터 파이프라인
================================================================================

[기존 구간]

Python log_gen.py
   |
   | sensor_json.log / sensor_text.log
   v
Fluent Bit
   |-------------------------------|
   | JSON                          | TEXT (선택 경로 / 기존 설정에서는 주석)
   v                               v
factory-json-topic              Logstash
                                   |
                                   v
                            factory-text-topic
   |                               |
   +---------------+---------------+
                   v
                Kafka -> 데이터 폭주시 안정적공급(누락x), 대량 처리 안정적, 공급/소비 분린(브로커)
                   |
                   | Consume
                   v
                Vector
                   |
                   | PutRecord / PutRecordBatch
                   v
            Amazon Data Firehose

--------------------------------------------------------------------------------
여기까지 이전 Kafka/Vector/Firehose 수업과 같은 방향성
--------------------------------------------------------------------------------

[변경되는 지점]

기존 : Firehose -> OpenSearch
변경 : Firehose -> S3 Bronze

                   |
                   v
             S3 Data Lake
             ├─ bronze/   JSONL.GZ
             ├─ silver/   Parquet
             ├─ reject/   JSON
             └─ gold/     Parquet
                   ^
                   |
            EventBridge (매시간 10분) : 스케줄링 처리, 매시간 10분에 Step Functions 지시
                   |
                   v
            Step Functions : 7개의 job을 순차 작동하여 데이터 처리 -> 배치 오케스트레이션(EventBridge 포함)
                   |
       +-----------+-----------------------------+
       |                                         |
       v                                         |
1. Lambda CheckBronze                            |
       |                                         |
       v                                         |
2. Choice : Bronze 있음?                         |
       | YES                                     |
       v                                         |
3. Glue Bronze -> Silver ----------------------> S3 Silver
       |                                         |
       v                                         |
4. Athena MSCK REPAIR                            |
       |                                         |
       v                                         |
5. Lambda Cleanup Gold                           |
       |                                         |
       v                                         |
6. Athena Silver -> Gold ----------------------> S3 Gold
       |                                         |
       v                                         |
7. Lambda Quality Check                          |
       |                                         |
       +---- SUCCESS -> SNS                      |
       +---- FAILURE -> SNS                      |
                                                 |
            Glue Data Catalog <------------------+
                   |
                   v
                Athena : 최종 조회 -> 결과셋 -> 대시보드/기타 서비스 전개

================================================================================
핵심
================================================================================

기존 수업
  Collect -> Broker -> Consume -> Deliver -> Search
  Fluent Bit -> Kafka -> Vector -> Firehose -> OpenSearch

이번 업그레이드
  Collect -> Broker -> Consume -> Deliver -> Store -> Orchestrate -> Transform -> Analyze
  Fluent Bit -> Kafka -> Vector -> Firehose -> S3 -> EventBridge -> Step Functions -> Glue/Athena

파이썬 작성 (task 작업)
    - lambda 처리 -> s3 저장
    - glue job (ETL) 처리 -> s3 저장
```

# Step Functions
```
S3 Bronze
   
EventBridge
   ↓
Step Functions
   ├─ Lambda : Bronze 존재 확인
   ├─ Glue   : Bronze → Silver Parquet
   ├─ Athena : Silver Partition 등록
   ├─ Lambda : 기존 Gold 삭제
   ├─ Athena : Silver → Gold 집계
   ├─ Lambda : Gold 품질검사
   └─ SNS    : 성공/실패
                ↓
        S3 Silver / Gold
```

# 인프라 구성
- 0. opensearch 제거
     - opensearch.tf 삭제
     - variables.tf에서 opensearch 관련 변수 삭제
     - firehose.tf에서 opensearch 구성삭제

- 1. 변수명 조정 => 금요일 인프라 구분

- 2. firehose에서 s3로 적제되게 조정 -> Data Lake 구성완료
```
eventbridge.tf
stepfunctions.tf
glue.tf
catalog.tf
athena.tf
iam-xxx.tf
...
```