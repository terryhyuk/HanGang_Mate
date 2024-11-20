from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
import joblib

# FastAPI 애플리케이션 생성
app = FastAPI()

# 저장된 모델 파일 경로
usage_model_path = "xgb_usage_model.pkl"
parking_model_path = "xgb_parking_model.pkl"

# 모델 로드
usage_model = joblib.load(usage_model_path)
parking_model = joblib.load(parking_model_path)

# 입력 데이터 스키마 정의
class ParkingFeatures(BaseModel):
    요일: str
    휴일여부: int
    주차장명: str
    연도: int
    월: int
    일: int
    주차구획수: int

# 혼잡도 계산 함수
def calculate_congestion(parking_count, capacity):
    """
    주차대수를 기반으로 혼잡도를 계산합니다.
    :param parking_count: 예측된 주차대수
    :param capacity: 주차장의 최대 용량
    :return: 혼잡도 ('여유', '보통', '혼잡', '만차')
    """
    ratio = parking_count / capacity
    if ratio <= 0.5:
        return '여유'
    elif ratio <= 0.8:
        return '보통'
    elif ratio <= 1.0:
        return '혼잡'
    else:
        return '만차'

# 예측 API 엔드포인트
@app.post("/predict_parking")
async def predict_parking(features: ParkingFeatures):
    """
    주어진 입력 데이터를 기반으로 주차 예측 및 혼잡도를 반환합니다.
    :param features: 입력 데이터 (ParkingFeatures 스키마 기반)
    :return: 예측된 이용시간, 주차대수 및 혼잡도
    """
    # 입력 데이터를 DataFrame으로 변환
    input_data = pd.DataFrame([features.dict()])

    # 입력 데이터 원-핫 인코딩
    input_encoded = pd.get_dummies(input_data)
    input_encoded = input_encoded.reindex(columns=usage_model.estimators_[0].feature_names_in_, fill_value=0)

    # 이용시간 예측
    predicted_usage = usage_model.predict(input_encoded)

    # 예측된 이용시간을 입력 피처에 추가
    input_with_usage = pd.concat([
        pd.DataFrame(input_encoded),
        pd.DataFrame(predicted_usage, columns=['예측 아침 이용시간', '예측 낮 이용시간', '예측 저녁 이용시간'])
    ], axis=1)

    # 주차대수 예측
    predicted_parking = parking_model.predict(input_with_usage)

    # Python 기본 타입으로 변환
    predicted_usage = predicted_usage.tolist()
    predicted_parking = predicted_parking.tolist()

    # 혼잡도 계산
    congestion_results = {
        "예측 아침 혼잡도": calculate_congestion(predicted_parking[0][0], features.주차구획수),
        "예측 낮 혼잡도": calculate_congestion(predicted_parking[0][1], features.주차구획수),
        "예측 저녁 혼잡도": calculate_congestion(predicted_parking[0][2], features.주차구획수)
    }

    # 결과 반환
    return {
        "예측 이용시간": {
            "아침": predicted_usage[0][0],
            "낮": predicted_usage[0][1],
            "저녁": predicted_usage[0][2]
        },
        "예측 주차대수": {
            "아침": predicted_parking[0][0],
            "낮": predicted_parking[0][1],
            "저녁": predicted_parking[0][2]
        },
        "혼잡도": congestion_results
    }
