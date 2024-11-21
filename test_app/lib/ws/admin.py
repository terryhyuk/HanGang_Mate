"""
author : ws
Description : admin
Date : 1121
Usage : q&a list/answer page
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


# 전체 게시글 불러오기
@router.get("/selectpost")
async def selectpost(seq : str=None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "select * from post"
        curs.execute(sql,(seq))
        conn.commit()
        allpost = curs.fetchall()
        conn.close()
        return{'results' : allpost}
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results' : 'Error'}
    
# 답변 입력
@router.get("/answerpost")
async def answerpost(complete: str=None, answer: str=None, seq: str=None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql='update qa set complete=%s, answer=%s where seq=%s'
        curs.execute(sql, (complete, answer, seq))
        conn.commit()
        return{'results' : ['OK'], 'message':'답변이 등록 되었습니다.'}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return{'results' : 'Error'}
    finally:
        conn.close()
