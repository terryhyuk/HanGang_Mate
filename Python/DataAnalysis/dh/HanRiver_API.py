import requests
import json
import time

# API 데이터 요청 함수
def fetch_data(url):
    # 주어진 URL로 GET 요청을 보내고 응답을 받음
    response = requests.get(url)
    
    # 응답 상태 코드가 200(성공)이면 JSON 데이터를 반환
    if response.status_code == 200:
        return response.json()
    else:
        # 상태 코드가 200이 아니면 오류 메시지 출력
        print(f"Error: {response.status_code}")
        return None

# 실시간 인구 및 혼잡도 정보 추출 함수
def extract_congestion_info(city_data):
    # 'LIVE_PPLTN_STTS' 키로부터 실시간 인구 현황 데이터 추출
    live_ppltn = city_data.get('LIVE_PPLTN_STTS', [])
    # 첫 번째 인구 정보 항목을 가져오거나 없으면 빈 딕셔너리 반환
    congestion_info = live_ppltn[0] if live_ppltn else {}
    
    # 추출한 데이터를 딕셔너리 형태로 반환
    return {
        "장소명": city_data.get("AREA_NM", "정보 없음"),  # 장소명
        "장소 코드": city_data.get("AREA_CD", "정보 없음"),  # 장소 코드
        "장소 혼잡도 지표": congestion_info.get("AREA_CONGEST_LVL", "정보 없음"),  # 혼잡도 지표
        "장소 혼잡도 지표 관련 메세지": congestion_info.get("AREA_CONGEST_MSG", "정보 없음"),  # 혼잡도 메세지
        "실시간 인구 현황": congestion_info.get("AREA_PPLTN_MIN", "정보 없음") + " ~ " + congestion_info.get("AREA_PPLTN_MAX", "정보 없음")  # 실시간 인구 현황
    }

# 주차장 중복 제거 및 최신 정보 선택 함수
def extract_unique_parking_info(city_data):
    # 'PRK_STTS' 키로부터 주차장 상태 정보 추출
    parking_data = city_data.get("PRK_STTS", [])
    unique_parking = {}
    
    # 주차장 데이터에서 중복된 주차장 정보를 제거하고 최신 정보만 유지
    for prk in parking_data:
        key = (prk.get("PRK_NM"), prk.get("PRK_CD"))  # 주차장 이름과 코드로 고유 키 생성
        if key not in unique_parking or prk.get("CUR_PRK_TIME"):  # 최신 정보가 있으면 업데이트
            unique_parking[key] = prk
    
    # 고유한 주차장 정보만 리스트로 반환
    return list(unique_parking.values())

# 날씨 현황 정보 추출 함수
def extract_weather_info(city_data):
    # 'WEATHER_STTS' 키로부터 날씨 상태 데이터 추출 (리스트일 경우 첫 번째 항목 선택)
    weather_data = city_data.get('WEATHER_STTS', [])
    weather_info = weather_data[0] if weather_data else {}  # 첫 번째 항목이 있으면 가져오고, 없으면 빈 딕셔너리
    
    # 추출한 날씨 정보를 딕셔너리 형태로 반환
    return {
        "기온": weather_info.get("TEMP", "정보 없음"),  # 기온
        "최고기온":weather_info.get("MAX_TEMP", "정보없음"), # 최고기온 
        "체감 온도": weather_info.get("SENSIBLE_TEMP", "정보 없음"),  # 체감 온도
        "강수" : weather_info.get("PRECPT_TYPE", "정보 없음"), # 강수
        "습도": weather_info.get("HUMIDITY", "정보 없음"),  # 습도
        "풍향": weather_info.get("WIND_DIRCT", "정보 없음"),  # 바람 방향
        "통합대기환경지수": weather_info.get("AIR_IDX_MVL", "정보 없음"),  # 통합 대기 환경 지수
        "통합대시환경지수메세지": weather_info.get("AIR_MSG", "정보 없음"),  # 통합 대기 환경 지수 메시지
    }

# 전체 데이터 처리 함수
def process_city_data(data):
    # 'CITYDATA' 키로부터 도시 데이터 추출
    city_data = data.get('CITYDATA', {})
    
    # 인구 및 혼잡도 정보 추출
    congestion_info = extract_congestion_info(city_data)
    # 중복된 주차장 정보 처리 후 고유한 주차장 정보 리스트 추출
    unique_parking_list = extract_unique_parking_info(city_data)
    # 날씨 현황 정보 추출
    weather_info = extract_weather_info(city_data)
    
    # 필요한 모든 데이터를 딕셔너리 형태로 반환
    return {
        **congestion_info,  # 인구 및 혼잡도 정보
        "전체도로소통평균속도": city_data.get("ROAD_TRAFFIC_SPD", "정보 없음"),  # 도로 소통 평균 속도
        "도로소통현황 업데이트 시간": city_data.get("ROAD_TRAFFIC_TIME", "정보 없음"),  # 도로 소통 현황 업데이트 시간
        "전체도로소통평균현황 메세지": city_data.get("ROAD_MSG", "정보 없음"),  # 도로 소통 현황 메시지
        "주차장 현황": unique_parking_list,  # 주차장 현황
        **weather_info  # 날씨 현황 정보
    }

# 결과 출력 함수
def print_data(data):
    # 처리된 데이터를 읽기 쉬운 형식으로 출력
    print("\n추출한 데이터 (row 형태):")
    print(json.dumps(data, ensure_ascii=False, indent=4))

# 실행 함수
def main(pname):
    # 시작 시간 기록
    start_time = time.time()

    # API URL 설정 (JSON 형식)
    url = f'http://openapi.seoul.go.kr:8088/434675486868617235394264587a4e/json/citydata/1/1000/{pname}'

    # 데이터 가져오기
    data = fetch_data(url)
    
    # 데이터가 유효하면 처리 후 출력
    if data:
        processed_data = process_city_data(data)
        print_data(processed_data)

    # 종료 시간 기록 및 실행 시간 출력
    end_time = time.time()
    print(f"\n코드 실행 시간: {end_time - start_time:.4f}초")

# 프로그램 실행
if __name__ == "__main__":
    main()