"""
author : ws
Description : admin
Date : 1121
Usage : q&a list/answer page
24.11.22 주차장 이름 불러와서 보여주도록 수정(JY)
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

# 선택 post 불러오기
@router.get("/showpost")
async def showpost(seq: int):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
            SELECT q.user_email, h.pname, q.question, q.answer 
            FROM qa q 
            LEFT JOIN hanriver h ON q.hanriver_seq = h.seq 
            WHERE q.seq = %s
        """
        curs.execute(sql, (seq,))
        result = curs.fetchone()
        return {'results': result}
    except Exception as e:
        print("Error", e)
        return {'results': None}
    finally:
        conn.close()
    
# 답변 입력
@router.get("/answerpost")
async def answerpost(complete: str=None, answer: str=None, seq: str=None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql='update qa set complete=%s, answer=%s where seq=%s'
        curs.execute(sql, (complete, answer, seq))
        conn.commit()
        return{'results' : 'OK'}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return{'results' : 'Error'}
    finally:
        conn.close()
