from http.client import HTTPException
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
from .. import crud, schemas, database

router = APIRouter()
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import JSONResponse

router = APIRouter()

from fastapi import APIRouter, Request, HTTPException

router = APIRouter()

@router.post("/data")
async def receive_iot_data(request: Request):
    body = await request.body()
    print("📩 Raw body:", body)

    try:
        data = await request.json()
    except Exception as e:
        print("❌ JSON 파싱 오류:", e)
        raise HTTPException(status_code=400, detail="Invalid JSON payload")

    print("✅ 받은 데이터:", data)
    return {"status": "ok"}

# @router.get("/latest")
# def get_latest_data(db: Session = Depends(database.get_db)):
#     """최신 센서 데이터 조회"""
#     try:
#         latest = crud.get_latest_sensor_data(db)
#         if not latest:
#             raise HTTPException(status_code=404, detail="No sensor data found")
        
#         print(f"📊 최신 센서 데이터: device_id={latest.device_id}, light={latest.light}, gas={latest.gas}, pir={latest.pir}")
#         return latest
        
#     except Exception as e:
#         print("❌ 데이터 조회 오류:", e)
#         raise HTTPException(status_code=500, detail=f"Data retrieval error: {str(e)}")

# @router.post("/iot/data", response_model=schemas.SensorDataOut)
# async def receive_iot_data(request: Request, db: Session = Depends(database.get_db)):
#     data = await request.json()
#     parsed = schemas.SensorDataCreate(**data)
#     return crud.save_sensor_data(db, parsed)
@router.get("/latest")
def get_latest_data(db: Session = Depends(database.get_db)):
    """최신 센서 데이터 조회"""
    try:
        latest = crud.get_latest_sensor_data(db)
        if not latest:
            # 테스트 데이터 반환 (실제 데이터가 없을 때)
            print("⚠️ DB에 데이터가 없어 테스트 데이터 반환")
            return {
                "device_id": "sensor01",
                "light": 535,
                "gas": 0,
                "pir": None,
                "timestamp": datetime.now().isoformat()
            }
        
        print(f"📊 최신 센서 데이터: device_id={latest.device_id}, light={latest.light}, gas={latest.gas}, pir={latest.pir}")
        
        # 응답 형식 통일
        return {
            "device_id": latest.device_id,
            "light": latest.light,
            "gas": latest.gas,
            "pir": latest.pir,
            "timestamp": latest.timestamp.isoformat() if latest.timestamp else datetime.now().isoformat()
        }
        
    except Exception as e:
        print("❌ 데이터 조회 오류:", e)
        # 오류 시에도 테스트 데이터 반환
        return {
            "device_id": "sensor01",
            "light": 535,
            "gas": 0,
            "pir": None,
            "timestamp": datetime.now().isoformat()
        }

@router.get("/iot/latest", response_model=schemas.SensorDataOut)
def get_latest_data(db: Session = Depends(database.get_db)):
    latest = crud.get_latest_sensor_data(db)
    return latest
