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
async def select(id: str=None):
    conn = connect()
    curs = conn.cursor()

    sql = "select email, name, observer from user where email=%s"
    curs.execute(sql, (id,))
    rows = curs.fetchall()
    conn.close()

    result = [{'id' : row[0], 'name' : row[1], 'observer' : row[2]} for row in rows]
    return {'results' : result}



@router.get("/insertuser")
async def insert(email: str=None, name: str=None, observer: str=None):
    conn = connect()
    curs = conn.cursor()

    try:
        sql ="insert into user(email, name) values (%s,%s)"
        curs.execute(sql, (id, name))
        conn.commit()
        conn.close()
        return {'results': 'OK'}

    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'result': 'Error'}