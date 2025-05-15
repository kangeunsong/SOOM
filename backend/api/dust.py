from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import AirQuality
from ..services.dust_service import DustService
from datetime import datetime, timedelta
from .. import schemas
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
router = APIRouter(
    prefix="/api/dust",
    tags=["dust"],
    responses={404: {"description": "Not found"}},
)

dust_service = DustService()

@router.get("/current/{location_code}", response_model=schemas.AirQuality)
async def get_current_air_quality(location_code: str, db: Session = Depends(get_db)):
    """특정 위치의 최신 미세먼지 정보 조회"""
    air_quality = db.query(AirQuality).filter(
        AirQuality.location_code == location_code
    ).order_by(AirQuality.recorded_at.desc()).first()
    
    if air_quality is None:
        dust_data = await dust_service.fetch_dust_data(location_code)
        if dust_data:
            air_quality = await dust_service.save_dust_data(db, dust_data)
        else:
            raise HTTPException(status_code=404, detail="미세먼지 정보를 찾을 수 없습니다")

    if air_quality is None:
        raise HTTPException(status_code=500, detail="미세먼지 정보를 저장하지 못했습니다")

    return air_quality


@router.get("/history/{location_code}")
async def get_air_quality_history(location_code: str, days: int = 1, db: Session = Depends(get_db)):
    from datetime import datetime, timedelta
    from fastapi.encoders import jsonable_encoder
    from fastapi.responses import JSONResponse

    start_date = datetime.now() - timedelta(days=days)
    air_quality_list = db.query(AirQuality).filter(
        AirQuality.location_code == location_code,
        AirQuality.recorded_at >= start_date
    ).order_by(AirQuality.recorded_at.desc()).all()

    if not air_quality_list:
        raise HTTPException(status_code=404, detail="미세먼지 이력이 없습니다")

    return JSONResponse(
        content=jsonable_encoder(air_quality_list),
        media_type="application/json; charset=utf-8"
    )
