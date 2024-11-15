"""
author : yh
Description : select/insert
Date : 2024.11.14~
Usage : 게시판 전체보기, 게시판 글 등록
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
    
# 게시글 입력
@router.get("/insertpost")
async def insertpost(user_gmail: str=None, parking_name_seq: str = None, date: str=None, public: str=None, contents: str=None, complete: str=None, answer: str=None):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "insert into post(user_gmail, parking_name_seq, date, public, contents, complete, answer) values(%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql,(user_gmail, parking_name_seq, date, public, contents, complete, answer))
        conn.commit()
        return{'results' : ['OK'], 'message':'게시글이 등록 되었습니다.'}
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return{'results' : 'Error'}
    finally:
        conn.close()
