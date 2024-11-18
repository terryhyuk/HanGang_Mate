"""
author : 정섭
Description : DB에 있는 hanriver 목록 불러오기 
Date : 2024.11.17~
한강공원 목록 : 'http://127.0.0.1:8000/parking/select_hanriver?'
공원 주차장 목록 : 'http://127.0.0.1:8000/parking/selectlatlng?hname=' 
"""
from fastapi import APIRouter
import pymysql
import host
router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=host.ip,
        user='root',
        password='qwer1234',
        db='parking',
        charset='utf8'
    )
    return conn


### 정섭 : 공원별 주차장 이름, 위도 경도 불러오기
@router.get('/selectlatlng')
async def selectlatlng(hname : str=None ):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select pname,lat,lng from hanriver where hname = %s"
        curs.execute(sql,hname)
        presults = curs.fetchall()
        conn.close()
        pname = [i[0] for i in presults]
        lat = [i[1] for i in presults]
        lng = [i[2] for i in presults]
        return {'pname' : pname, 'lat' : lat, 'lng':lng}

    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results' : 'Error'}
    


### 정섭 : 공원 목록(드랍다운용) 불러오기
@router.get('/select_hanriver')
async def select_hanriver():
    conn = connect()
    curs = conn.cursor()
    try:
        sql = 'select distinct hname from hanriver'
        curs.execute(sql)
        results = curs.fetchall()
        conn.close()
        result = [i[0] for i in results]
        return {'results' :result}
    except Exception as e :
        conn.close()
        print(e)
        return {'error' : e}
    
