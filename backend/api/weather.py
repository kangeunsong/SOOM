from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from database import get_db
from models import Weather
from ..services.weather_service import WeatherService
from datetime import datetime, timedelta
from fastapi.responses import JSONResponse
import schemas

router = APIRouter(
    prefix="/api/weather",
    tags=["weather"],
    responses={404: {"description": "Not found"}},
)

weather_service = WeatherService()
from fastapi.encoders import jsonable_encoder  # 추가

@router.get("/current/{location_code}", response_model=schemas.Weather)
async def get_current_weather(location_code: str, db: Session = Depends(get_db)):
    """특정 위치의 최신 날씨 정보 조회"""
    weather = db.query(Weather).filter(
        Weather.location_code == location_code
    ).order_by(Weather.recorded_at.desc()).first()
    
    if weather is None:
        # DB에 없으면 실시간으로 가져오기
        weather_data = await weather_service.fetch_weather_data(location_code)
        if weather_data:
            weather = await weather_service.save_weather_data(db, weather_data)
        else:
            raise HTTPException(status_code=404, detail="날씨 정보를 찾을 수 없습니다")
    
    return JSONResponse(content=jsonable_encoder(weather), media_type="application/json; charset=utf-8")
@router.get("/history/{location_code}", response_model=List[schemas.Weather])
async def get_weather_history(
    location_code: str, 
    days: int = 1, 
    db: Session = Depends(get_db)
):
    """특정 위치의 날씨 이력 조회"""
    start_date = datetime.now() - timedelta(days=days)
    
    weather_history = db.query(Weather).filter(
        Weather.location_code == location_code,
        Weather.recorded_at >= start_date
    ).order_by(Weather.recorded_at.desc()).all()
    
    # 데이터가 없으면 빈 배열 반환 또는 샘플 데이터 반환
    if not weather_history:
        # 옵션 1: 빈 배열 반환
        return []
        
        # 옵션 2: 샘플 데이터 생성하여 반환
        # return generate_sample_weather_history(location_code, days)
    
    return weather_history