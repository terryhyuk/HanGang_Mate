"""
author : 정섭, JY(24.11.19 수정)
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

@router.get('/hanriver')
async def get_hanriver_data(hname: str = None):
    conn = connect()
    curs = conn.cursor()
    try:
        if hname:
            # 특정 공원의 주차장 정보 조회
            sql = "SELECT pname, lat, lng FROM hanriver WHERE hname = %s"
            curs.execute(sql, hname)
            results = curs.fetchall()
            data = {
                'pname': [r[0] for r in results],
                'lat': [r[1] for r in results],
                'lng': [r[2] for r in results]
            }
        else:
            # 전체 공원 목록 조회
            sql = "SELECT DISTINCT hname FROM hanriver"
            curs.execute(sql)
            results = curs.fetchall()
            data = {'results': [r[0] for r in results]}
        
        return data
    except Exception as e:
        print("Error:", e)
        return {'error': str(e)}
    finally:
        conn.close()