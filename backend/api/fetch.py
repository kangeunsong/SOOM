# backend/api/fetch.py

from fastapi import APIRouter, Depends
from backend.scheduler import fetch_and_save_data  # 비동기 함수 직접 호출
import asyncio

router = APIRouter()

@router.post("/fetch-now")
async def fetch_now():
    asyncio.create_task(fetch_and_save_data())
    return {"message": "데이터 수집이 시작되었습니다."}
