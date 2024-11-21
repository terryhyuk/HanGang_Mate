"""
author : yh, JY(24.11.21 수정)
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
async def selectpost(seq: int = None):
    conn = connect()
    curs = conn.cursor()
    try:
        if seq:
            sql = "SELECT * FROM qa WHERE seq = %s"
            curs.execute(sql, (seq,))
        else:
            sql = "SELECT * FROM qa"
            curs.execute(sql)
        
        posts = curs.fetchall()
        conn.close()
        return {'results': posts}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'results': 'Error'}

# 게시글 입력
@router.get("/insertpost")
async def insertpost(
    user_email: str = None, 
    hanriver_seq: int = None, 
    date: str = None, 
    public: str = None, 
    question: str = None, 
    complete: str = None, 
    answer: str = None
):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = """
            INSERT INTO qa(user_email, hanriver_seq, date, public, question, complete, answer) 
            VALUES(%s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (
            user_email, 
            hanriver_seq, 
            date, 
            public, 
            question, 
            complete, 
            answer
        ))
        conn.commit()
        return {
            'results': ['OK'], 
            'message': '게시글이 등록 되었습니다.'
        }
    except Exception as e:
        conn.rollback()
        print("Error", e)
        return {'results': 'Error'}
    finally:
        conn.close()



# 주차장 seq 가져오기
@router.get("/get_hanriver_seq")
async def get_hanriver_seq(hname: str):
    conn = connect()
    curs = conn.cursor()
    try:
        sql = "SELECT seq FROM hanriver WHERE hname = %s LIMIT 1"
        curs.execute(sql, (hname,))
        result = curs.fetchone()
        conn.close()
        return {'seq': result[0] if result else None}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'seq': None}