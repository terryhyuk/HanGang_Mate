"""
author: 
Description: 
Fixed: 
Usage: 
"""

from fastapi import FastAPI
# from test import router as test_router



app = FastAPI()
# app.include_router(test_router, prefix='/test', tags=['test'])



if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host = "127.0.0.1", port = 8000)