# 목표
- kafka 이해, 활용, 응용
- ELK, EFK에서
    - 데이터 전송/필터링/전처리 등 역활 담당
        - L:Logstash    -> 라이브러리 활용, 비정형데이터(text 로그파일) => 가공 => json 전송
        - F:Fluent-Bit  -> json 전송, text 전송
        - 센서 장비 + 장비등(배치) => 로그 발생 => 바로 전송(Fluent-Bit/Logstash) => kafka 전송 => vector => firhose => opensearch/s3 => 검색 서비스 활용
- opensearch
    - E:엘라스틱서치의 AWS 버전(저작권 오픈된 버전)
    - 검색엔진, 인덱스 검색
    - 대시보드 <-> K:키바나

# 목표 시스템
```
[ LAYER ]          [ COMPONENT ]          [ PROTOCOL / ACTION ]            [ DATA FORMAT ]
====================================================================================================
SOURCE       :     Python (log_gen.py)  ----( Write to File )---->  [ /sensor_logs/*.log ]
               |                                                                   |
               |                                                            ( Shared Volume )
               v                                                                   |
INGESTION    :     Fluent Bit (Agent)   <---( Tailing File  )----------------------+
               |          |
               |          | [ CHANNEL A: DIRECT BYPASS ]
               |          +--------------------------------------------( Produce )--+
               |          |                                                         |
               |          | [ CHANNEL B: PROXY ROUTE  ]                             |
               |          +----( Forward )----> [ Logstash ] ----( Produce )--+     |
               |                                     |                        |     |
               v                                     v                        v     v
TRANSFORM    : (A: Bypass)  +--[ Grok    : Pattern Matching & Extract Fields   ]--+ |
               |            +--[ Mutate  : Data Type Conversion (Str->Float)   ]--+ |
               |            +--[ Tagging : Add Metadata for Conditional Alerts ]--+ |
               |                                                              |     |
MESSAGING    :     Kafka / MSK (Broker) <-------------------------------------+-----+
               |          |             ( Merge Structured & Processed Data )
               |          |
               |          +----( Topic A: factory-json-topic ) <--- [Channel A Result]
               |          +----( Topic B: factory-text-topic ) <--- [Channel B Result]
               v                                                               |
               v                                                               |
                                                                        kafka connect / ui
                                                                                |
                                                                                v               
VISUALIZE    :     OpenSearch (DB)      <---( Indexing & Search )---->  DASHBOARD (Kibana)
====================================================================================================
```

```
                  ┌─ sensor_json.log (반정형 데이터)
Python 로그 생성기 ┤
                  └─ sensor_text.log (비정형 데이터)
                         │
                         ▼
                    Fluent Bit
                    /         \
                   /           \
          JSON 직결             TEXT
             │                  │
             │               HTTP
             │                  ▼
             │              Logstash
             │              Grok 변환 -> 비정형 => 반정형 처리
             │                  │
             ▼                  ▼
 factory-json-topic      factory-text-topic
             \                 /
              \               /
                 Apache Kafka (브로커 데이터 수신) -> AWS 외부 or EC2 or 쿠버네티스 상주 or MSK(전용 AWS 서비스)
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
       Kafka UI(대시보드)        Vector (서비스)
                                  │
                                  ▼
                           AWS Firehose -> 버퍼링 -> s3(브론즈) or opensearch(인덱스(센서/공장관리단위) 검색)
```

# 개발 환경 구성
- docker-compose.yaml 구성
```
    docker compose up -d
```

- kafka <-> kinesis
    - 대규모 실시간 데이터를 처리하기 위해 만든 오픈소스 분산형 이벤트 스트리밍 플랫폼
    - 프로듀서, 컨슈머, 토픽
    - 수 밀리초 단위 초저지연 전송 유리
    - AWS MSK로 제공
    - 최신 방식으로 구성

- Fluentd(40~-60MB) <-> Fluent-Bit(1~5MB)
    - 태그 기반 라우팅 도구
    - Ruby+C 결합 구조 <-> C
    - 서비스 세팅 후 fluent-bit.conf 설정으로 끝
    - Fluent-Bit 목적
        - 데이터 수집, 처리, 전달 (ETL 도구)
        - 경량형 오픈소스 로그 프로세서
        - 고가용성, 고성능처리, 데이터 처리 안정성등 장점
        - Input 스트림으로 파일, 버퍼, 라우팅, ... 대부분 지원
        - Output 스트림 대부분 서비스 모두 지원 (kafka/opensearch/s3/...)
            - 지원 플러그인 활용
    - fluent-bit.conf -> 수정 -> docker compose restart -> 수정내용이 반영됨

    