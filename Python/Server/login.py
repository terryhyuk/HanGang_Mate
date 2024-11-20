"""
author : JY
Description : FastAPI Router about Google Login
Date : 2024.11.18~
"""

from fastapi import APIRouter 
import pymysql
import host

router = APIRouter()

def connect():
    conn = pymysql.connect(
        host=host.ip,
        user='root',
        passwd='qwer1234',
        db='parking',
        charset='utf8'
    )
    return conn



@router.get("/selectuser")
async def select(email: str=None):
    conn = connect()
    curs = conn.cursor()

    sql = "select email, name, observer from user where email=%s"
    curs.execute(sql, (email,))
    rows = curs.fetchall()
    conn.close()

    result = [{'email' : row[0], 'name' : row[1], 'observer' : row[2]} for row in rows]
    return {'results' : result}



@router.get("/insertuser")
async def insert(email: str=None, name: str=None, observer: str=None):
    conn = connect()
    curs = conn.cursor()

    try:
        # 먼저 해당 이메일이 존재하는지 확인
        check_sql = "SELECT email FROM user WHERE email=%s"
        curs.execute(check_sql, (email,))
        exists = curs.fetchone()
        
        if exists:
            conn.close()
            return {'results': 'Already exists'}
            
        # 존재하지 않는 경우에만 삽입
        sql ="insert into user(email, name, observer) values (%s,%s,%s)"
        curs.execute(sql, (email, name, observer))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}