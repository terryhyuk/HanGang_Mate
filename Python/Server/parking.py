"""
author : yh
Description : post
Date : 2024.11.14~
Usage : FastAPI Router about post
"""

from fastapi import FastAPI
from post import router as post_router
import pymysql

app = FastAPI()
app.include_router(post_router, prefix="/post", tags=['post'])

def connect():
    conn = pymysql.connect(
        host='192.168.50.87',
        user='root',
        password='qwer1234',
        db='parking',
        charset='utf8'
    )
    return conn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)