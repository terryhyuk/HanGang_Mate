"""
author: 
Description: 
Fixed: 
Usage: 
"""


from fastapi import APIRouter
import pymysql
import host
router = APIRouter()



def connect():
    conn = pymysql.connect(
        host=host.remote,
        user='root',
        password='qwer1234',
        charset='utf8',
        db=''
    )
    return conn