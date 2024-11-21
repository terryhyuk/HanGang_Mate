"""
author : yh
Description : post
Date : 2024.11.14~
Usage : FastAPI Router about post
"""

from fastapi import FastAPI
from post import router as post_router
from park_info import router as parking_router
from login import router as login_router
from model import router as model_router
from HanRiver_API import router as hanriver_router
import pymysql
import host

app = FastAPI()
app.include_router(post_router, prefix="/post", tags=['post'])
app.include_router(parking_router, prefix="/parking", tags=['parking'])
app.include_router(login_router, prefix="/user", tags=['login'])
app.include_router(model_router, prefix="/predict", tags=["Model"])
app.include_router(hanriver_router, prefix="/hanriver", tags=["Live"])


def connect():
    conn = pymysql.connect(
        host=host.ip,
        user='root',
        password='qwer1234',
        db='parking',
        charset='utf8'
    )
    return conn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host='127.0.0.1', port=8000, reload=True)