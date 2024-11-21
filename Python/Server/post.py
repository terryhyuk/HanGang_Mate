"""
author : JY(24.11.21 수정)
Description : 게시글 관련
Date : 2024.11.14~
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
async def selectpost(page: int = 1, limit: int = 10, user_email: str = None, observer: str = 'false'):
    conn = connect()
    curs = conn.cursor(pymysql.cursors.DictCursor)  # DictCursor 사용
    try:
        # 권한에 따른 WHERE 절 구성
        params = []
        if observer != 'true':
            where_clause = "WHERE public = 'Y'"
            if user_email:
                where_clause += " OR user_email = %s"
                params.append(user_email)
        else:
            where_clause = ""  # 관리자는 모든 게시글 조회 가능
            
        # 전체 게시글 수 조회
        count_sql = f"SELECT COUNT(*) as count FROM qa {where_clause}"
        curs.execute(count_sql, params)
        total_count = curs.fetchone()['count']
        
        # 페이지네이션된 게시글 조회
        offset = (page - 1) * limit
        sql = f"""
            SELECT 
                seq, user_email, hanriver_seq, 
                date, public, question, 
                complete, answer 
            FROM qa 
            {where_clause}
            ORDER BY seq DESC 
            LIMIT %s OFFSET %s
        """
        params.extend([limit, offset])
        curs.execute(sql, params)
        posts = curs.fetchall()
        
        conn.close()
        return {
            'results': posts,
            'total_count': total_count,
            'current_page': page,
            'total_pages': (total_count + limit - 1) // limit
        }
    except Exception as e:
        conn.close()
        print("Error", e)
        return{'results': 'Error'}
    


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
            INSERT INTO qa(
                user_email, 
                hanriver_seq, 
                date, 
                public, 
                question, 
                complete, 
                answer
            ) VALUES(%s, %s, %s, %s, %s, %s, %s)
        """
        curs.execute(sql, (
            user_email, 
            hanriver_seq, 
            date, 
            public, 
            question, 
            complete or 'N',  # complete가 None이면 'N' 사용
            answer or ''      # answer가 None이면 빈 문자열 사용
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
    curs = conn.cursor(pymysql.cursors.DictCursor)
    try:
        sql = "SELECT seq FROM hanriver WHERE hname = %s LIMIT 1"
        curs.execute(sql, (hname,))
        result = curs.fetchone()
        conn.close()
        return {'seq': result['seq'] if result else None}
    except Exception as e:
        conn.close()
        print("Error", e)
        return {'seq': None}