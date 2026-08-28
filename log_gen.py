"""
Smart Factory Sensor 로그 생성기
- 해당 파이썬 파일은 장비로 이해 -> 장비가 신호/로그 발생 -> 감지 -> 데이터 파이프라인 전개 구조
- 로그 파일
    - sensor_json.log : JSONL 포멧
    - sensor_text.log : Text  포멧
    - 각 파일이 10MB 도달하면 로테이션 시도 -> xxx-1, xxx-2,... 파일 신규로 생성
    - 최대 유지 파일수는 5개 설정, 6개가 되면 가장 오래된 파일 1개를 삭제
"""

import datetime
import json
import logging
import os
import random
import time
from logging.handlers import RotatingFileHandler

# 환경 변수
LOG_DIR = "./sensor_logs"
MAX_LOG_BYTES = 10 * 1024 * 1024 # 10MB
BACKUP_COUNT = 5
os.makedirs(LOG_DIR, exist_ok=True)

# 로그 파일별 기록, 로테이션 관리 .. 객체 구성
def create_rotation_logger(name:str,filename:str) -> logging.Logger:
    logger = logging.getLogger(name)    # 고유한 문자열로 구분되는 로거 객체 획득
    logger.setLevel(logging.INFO)       # 정보 레벨 로그만 수집
    logger.propagate = False            # 상위 레벨로 현재 로그를 전달할것인가?
    if logger.handlers:
        return logger
    
    # 핸들러 구성  (최대 크기, 최대 개수, 로테이션)
    handler = RotatingFileHandler(
        os.path.join(LOG_DIR,filename), # ./sensor_logs/sensor_json.log
        maxBytes=MAX_LOG_BYTES,
        backupCount=BACKUP_COUNT,
        encoding="utf-8"
    )
    # 포맷지정, 실제 메시지 내용만 담는 로그로 구성
    handler.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(logger)
    return logger

    pass

json_logger = create_rotation_logger("sensor_json","sensor_json.log")
text_logger = create_rotation_logger("sensor_json","sensor_text.log")

# 로그 발생
def generator_logs():
    # 오픈서치에서 data로 인식하게 하기 위해서 ISO-8601 사용
    timestamp = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
    data = {
        "timestamp"         : timestamp, 
        "sensor_id"         : "AI-FACTORY-001",         # 센서 id
        "temperature"       : round(random.uniform(70.0,120.0), 1), 
        "humidity"          : round(random.uniform(30.0,80.0), 1),
        "status"            : "RUNNING"
    }
    pass

# 메인 함수
def main () -> None:
    try:
        while True:
            generator_logs()
            time.sleep(2)
        
    except Exception as e:
        print("종료처리" , e)


# 엔트리 포인트
if __name__ == "__main__":
    print("센서 발생 시작!")
    main()