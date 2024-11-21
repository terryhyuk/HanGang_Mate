"""
작성자: 하동훈  
작성일시: 2024-11-21  
파일 내용: 여의도와 뚝섬 한강공원의 주차 예측 및 혼잡도 계산을 위한 FastAPI 서버 구현.  
          - 이용시간 및 주차대수 예측 모델을 사용하여 혼잡도를 계산.  
          - 두 공원의 입력 데이터를 구분하여 처리.  
usage: 'http://127.0.0.1:8000/predict/predict_yeouido'
usage: 'http://127.0.0.1:8000/predict/predict_ttukseom'
"""

from fastapi import APIRouter
from pydantic import BaseModel
import pandas as pd
import numpy as np
import joblib

router = APIRouter()

# 모델 및 피처 로드 (여의도)
yeouido_usage_model = joblib.load('Yeouido_usage_model.pkl')
yeouido_parking_model = joblib.load('Yeouido_parking_model.pkl')
yeouido_features_usage = joblib.load('Yeouido_features_usage.pkl')
yeouido_features_parking = joblib.load('Yeouido_features_parking.pkl')

# 모델 및 피처 로드 (뚝섬)
ttukseom_usage_model = joblib.load('Ttukseom_usage_model.pkl')
ttukseom_parking_model = joblib.load('Ttukseom_parking_model.pkl')
ttukseom_features_usage = joblib.load('Ttukseom_features_usage.pkl')
ttukseom_features_parking = joblib.load('Ttukseom_features_parking.pkl')

# 입력 데이터 스키마 정의 (여의도)
class YeouidoFeatures(BaseModel):
    요일: int
    휴일여부: int
    주차장명: str
    연도: int
    월: int
    일: int
    주차구획수: int

# 입력 데이터 스키마 정의 (뚝섬)
class TtukseomFeatures(BaseModel):
    요일: int
    휴일여부: int
    주차장명: str
    연도: int
    월: int
    최고기온: float
    주차구획수: int

def calculate_congestion(parking_count, capacity):
    ratio = parking_count / capacity
    if ratio <= 0.5:
        return '여유'
    elif ratio <= 0.8:
        return '보통'
    elif ratio <= 1.0:
        return '혼잡'
    else:
        return '만차'

def convert_to_python_type(data):
    """
    numpy 타입을 Python 타입으로 변환합니다.
    """
    if isinstance(data, (list, tuple)):
        return [float(item) if isinstance(item, (np.float32, np.float64)) else item for item in data]
    elif isinstance(data, (np.float32, np.float64)):
        return float(data)
    return data

@router.post("/predict_yeouido")
async def predict_yeouido(features: YeouidoFeatures):
    # 입력 데이터를 DataFrame으로 변환
    input_data = pd.DataFrame([features.model_dump()])

    # 입력 데이터 원-핫 인코딩
    input_encoded = pd.get_dummies(input_data)

    # 누락된 피처를 모델이 필요로 하는 피처 세트에 맞게 추가
    for missing_feature in set(yeouido_features_usage) - set(input_encoded.columns):
        input_encoded[missing_feature] = 0

    # 불필요한 피처 제거 (예: 주차구획수는 혼잡도 계산에만 사용)
    input_encoded = input_encoded[yeouido_features_usage]

    # 이용시간 예측
    predicted_usage = yeouido_usage_model.predict(input_encoded)

    # 예측된 이용시간을 입력 피처에 추가
    input_with_usage = pd.concat([
        input_encoded,
        pd.DataFrame(predicted_usage, columns=['예측 아침 이용시간', '예측 낮 이용시간', '예측 저녁 이용시간'])
    ], axis=1)

    # 주차대수 예측
    for missing_feature in set(yeouido_features_parking) - set(input_with_usage.columns):
        input_with_usage[missing_feature] = 0

    input_with_usage = input_with_usage[yeouido_features_parking]
    predicted_parking = yeouido_parking_model.predict(input_with_usage)

    # 혼잡도 계산
    congestion_results = {
        "예측 아침 혼잡도": calculate_congestion(predicted_parking[0][0], features.주차구획수),
        "예측 낮 혼잡도": calculate_congestion(predicted_parking[0][1], features.주차구획수),
        "예측 저녁 혼잡도": calculate_congestion(predicted_parking[0][2], features.주차구획수)
    }

    # 데이터를 Python 기본 타입으로 변환
    predicted_usage = convert_to_python_type(predicted_usage.tolist())
    predicted_parking = convert_to_python_type(predicted_parking.tolist())
    congestion_results = convert_to_python_type(congestion_results)

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

@router.post("/predict_ttukseom")
async def predict_ttukseom(features: TtukseomFeatures):
    # 입력 데이터를 DataFrame으로 변환
    input_data = pd.DataFrame([features.model_dump()])

    # 입력 데이터 원-핫 인코딩
    input_encoded = pd.get_dummies(input_data)

    # 누락된 피처를 모델이 필요로 하는 피처 세트에 맞게 추가
    for missing_feature in set(ttukseom_features_usage) - set(input_encoded.columns):
        input_encoded[missing_feature] = 0

    # 불필요한 피처 제거 (예: 주차구획수는 혼잡도 계산에만 사용)
    input_encoded = input_encoded[ttukseom_features_usage]

    # 이용시간 예측
    predicted_usage = ttukseom_usage_model.predict(input_encoded)

    # 예측된 이용시간을 입력 피처에 추가
    input_with_usage = pd.concat([
        input_encoded,
        pd.DataFrame(predicted_usage, columns=['예측 아침 이용시간', '예측 낮 이용시간', '예측 저녁 이용시간'])
    ], axis=1)

    # 주차대수 예측
    for missing_feature in set(ttukseom_features_parking) - set(input_with_usage.columns):
        input_with_usage[missing_feature] = 0

    input_with_usage = input_with_usage[ttukseom_features_parking]
    predicted_parking = ttukseom_parking_model.predict(input_with_usage)

    # 혼잡도 계산
    congestion_results = {
        "예측 아침 혼잡도": calculate_congestion(predicted_parking[0][0], features.주차구획수),
        "예측 낮 혼잡도": calculate_congestion(predicted_parking[0][1], features.주차구획수),
        "예측 저녁 혼잡도": calculate_congestion(predicted_parking[0][2], features.주차구획수)
    }

    # 데이터를 Python 기본 타입으로 변환
    predicted_usage = convert_to_python_type(predicted_usage.tolist())
    predicted_parking = convert_to_python_type(predicted_parking.tolist())
    congestion_results = convert_to_python_type(congestion_results)

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
