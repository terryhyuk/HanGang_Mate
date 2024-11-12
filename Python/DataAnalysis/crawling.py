from fastapi import FastAPI
# import uvicorn
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

# FastAPI Instance 생성
# app = FastAPI()

# URL
url = "https://data.seoul.go.kr/SeoulRtd/?hotspotNm=%EB%A7%9D%EC%9B%90%ED%95%9C%EA%B0%95%EA%B3%B5%EC%9B%90&y=126.89926777366624&x=37.553280796716926"

# 1. 주차 현황 크롤링
def fetch_parking_data():
    options = Options()
    # options.headless = True  # 드라이버 띄우지 않고 사용 (헤드리스 모드)
    driver = webdriver.Chrome(options=options)

    driver.get(url)  # Selenium을 사용해 페이지 열기
    time.sleep(3)  # 페이지가 동적으로 로딩될 시간 대기

    soup = BeautifulSoup(driver.page_source, 'html.parser')

    parking_data = []

    # HTML 구조에 맞춰 데이터를 파싱
    for item in soup.select("#report_parking"):
        parking_data.append({
            "name": item.find("div", class_="side-report__public-parking-item-name").text.strip(),  # 주차장 이름
            "available_spaces": item.find("div", class_="side-report__parking-sortation-data-now").text.strip(),  # 잔여 주차 공간
            "rate_spaces": item.find("div", class_="side-report__parking-summary-percent-info").text.strip(),  # 전체 주차장 잔여율
            "parking_location": item.find("div", class_="side-report__public-parking-item-location").text.strip(),  # 위치
            "updated_time": item.find("span").text.strip(),  # 업데이트 시간
        })
    
    driver.quit()  # 크롬 드라이버 종료
    return parking_data

# 2. 인구 혼잡도 크롤링
def fetch_population_data():
    options = Options()
    options.headless = True  # 드라이버 띄우지 않고 사용 (헤드리스 모드)
    driver = webdriver.Chrome(options=options)

    driver.get(url)  # Selenium을 사용해 페이지 열기
    time.sleep(3)  # 페이지가 동적으로 로딩될 시간 대기

    # Selenium을 사용해 동적으로 렌더링된 HTML을 가져옴
    soup = BeautifulSoup(driver.page_source, 'html.parser')

    population_data = []

    # HTML 구조에 맞춰 데이터를 파싱
    for item in soup.select("#report_population > div.report_inner_wrap > div"):
        # 각 div 안에 있는 'rpt_data' 요소들을 모두 선택
        rate_texts_1 = item.select("div.rpt_data.rpt_pop_updown1.color_up") # 1시간 전 대비 증감률
        rate_texts_2 = item.select("div.rpt_data.rpt_pop_updown2.color_up") # 3시간 전 대비 증감률
        rate_texts_3 = item.select("div.rpt_data.rpt_pop_updown3.color_up") # 최근 28일 동시간 평균 대비 증감률

        # 각각의 증감률 요소를 순차적으로 처리
        for rate_text in rate_texts_1 + rate_texts_2 + rate_texts_3:  # 세 가지 항목을 합쳐서 처리
            rate = rate_text.get_text(strip=True)
            arrow_class = rate_text.get("class", [])
            if "arr_up" in arrow_class:
                arrow_direction = "Up"  # 증가를 나타내는 화살표
            elif "arr_down" in arrow_class:
                arrow_direction = "Down"  # 감소를 나타내는 화살표
            else:
                arrow_direction = "Neutral"  # 변화 없음 (중립 상태)

            # 색깔 표시 추가: 증감률에 따른 색깔 결정 (예시: 상승은 빨간색, 하락은 파란색, 중립은 회색)
            rate_color = ""
            if arrow_direction == "Up":
                rate_color = "red"  # 상승: 빨간색
            elif arrow_direction == "Down":
                rate_color = "blue"  # 하락: 파란색
            else:
                rate_color = "gray"  # 중립: 회색

            population_data.append({
                "congestion_level": item.find("h2 > b").text.strip(),  # 인구 혼잡도
                "population_rate": rate,  # 증감률
                "arrow_direction": arrow_direction,  # 화살표 방향
                "rate_color": rate_color,  # 증감률에 따른 색깔
                "cogestion_graph": item.find("#population_graph_pop > div:nth-child(1)").get("src"), # 실시간 인구 및 혼잡도 추이 전망
                "pre_hour_12_img": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.predict_div > div > div > img").get('src'), # 향후 12시간 전망 이미지
                "pre_most_population_time": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.predict_div > div > ul > li:nth-child(1) > b").text.strip(), # 향후 12시간 전망 인구 가장 많은 시간
                "pre_congestion": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.predict_div > div > ul > li:nth-child(2) > b").text.strip(), # 향후 12시간 전망 혼잡 정도
                "before_hour_12_img": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.flex.items-center.pt-2 > div > img").get("src"), # 지난 12시간 추이 이미지
                "before_most_population_time": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.flex.items-center.pt-2 > ul > li:nth-child(1) > b").text.strip(), # 지난 12시간 추이 인구 가장 많은 시간
                "before_congestion": item.find("#report_population > div.report_inner_wrap > div:nth-child(2) > div.flex.items-center.pt-2 > ul > li:nth-child(1) > b").text.strip(), # 지난 12시간 추이 혼잡 정도
                "updated_time": item.find("span").text.strip() # 업데이트 시간
            })

    driver.quit()  # 크롬 드라이버 종료
    return population_data

# 3. 도로 소통 크롤링
def fetch_traffic_data():
    options = Options()
    options.headless = True  # 드라이버 띄우지 않고 사용 (헤드리스 모드)
    driver = webdriver.Chrome(options=options)

    driver.get(url)  # Selenium을 사용해 페이지 열기
    time.sleep(3)  # 페이지가 동적으로 로딩될 시간 대기

    soup = BeautifulSoup(driver.page_source, 'html.parser')

    traffic_data = []

    # HTML 구조에 맞춰 데이터를 파싱 
    for item in soup.select("#report_traffic > div.report_inner_wrap"): 
        traffic_data.append({
            "road": item.find("도로 이름 요소").text.strip(),  # 도로 이름
            "traffic_status": item.find("#report_traffic > div.report_inner_wrap > div:nth-child(1) > h2 > b > span").text.strip(),  # 소통 상태
            "traffic_status_img": item.find("#report_traffic > div.report_inner_wrap > div:nth-child(1) > div.graphic_guage.road_graph_gauge > img").get('src'),  # 소통 상태 이미지
            "traffic_status_info": item.find("#report_traffic > div.report_inner_wrap > div:nth-child(1) > ul > li").text.strip(),  # 도로 혼잡도
            "optimal_time_slot": item.find("#report_traffic > div.report_inner_wrap > div:nth-child(2) > table > tbody > tr:nth-child(2) > td:nth-child(1) > b").text.strip(),  # 가장 원할한 시간대
            "congested_time_slot": item.find("#report_traffic > div.report_inner_wrap > div:nth-child(2) > table > tbody > tr:nth-child(2) > td:nth-child(2) > b").text.strip(),  # 가장 정체되던 시간대
        })
    
    driver.quit()  # 크롬 드라이버 종료
    return traffic_data

# 메인 함수에서 크롤링 데이터를 직접 출력하기
# if __name__ == "__main__":
parking_data = fetch_parking_data()
population_data = fetch_population_data()
traffic_data = fetch_traffic_data()

print("Parking Data:", parking_data)
print("Population Data:", population_data)
print("Traffic Data:", traffic_data)



# # FastAPI 엔드포인트 설정
# @app.get("/parking_data")
# async def get_parking_data():
#     return fetch_parking_data()

# @app.get("/population_data")
# async def get_population_data():
#     return fetch_population_data()

# @app.get("/traffic_data")
# async def get_traffic_data():
#     return fetch_traffic_data()