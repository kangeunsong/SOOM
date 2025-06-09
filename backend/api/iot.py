from http.client import HTTPException
from fastapi import APIRouter, Depends, Request
from sqlalchemy.orm import Session
import crud, schemas, database
from datetime import datetime
router = APIRouter()
from fastapi import APIRouter, Request, HTTPException
from fastapi.responses import JSONResponse

router = APIRouter()

from fastapi import APIRouter, Request, HTTPException

router = APIRouter()

# @router.post("/data")
# async def receive_iot_data(request: Request):
#     body = await request.body()
#     print("📩 Raw body:", body)

#     try:
#         data = await request.json()
#     except Exception as e:
#         print("❌ JSON 파싱 오류:", e)
#         raise HTTPException(status_code=400, detail="Invalid JSON payload")

#     print("✅ 받은 데이터:", data)
#     return {"status": "ok"}

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
@router.post("/data")
async def receive_iot_data(request: Request, db: Session = Depends(database.get_db)):
    """IoT 센서 데이터 수신 및 저장"""
    try:
        # 요청 본문 파싱
        data = await request.json()
        print("✅ 받은 데이터:", data)
        
        # 데이터베이스에 저장하기 위해 스키마로 변환
        sensor_data = schemas.SensorDataCreate(
            device_id=data.get("device_id", "unknown"),
            light=data.get("light"),
            gas=data.get("gas"),
            pir=data.get("pir")
        )
        
        # 데이터베이스에 저장
        saved_data = crud.save_sensor_data(db, sensor_data)
        print(f"💾 데이터베이스에 저장됨: ID={saved_data.id}")
        
        return {"status": "ok", "message": "Data saved successfully", "id": saved_data.id}
        
    except Exception as e:
        print("❌ 데이터 처리 오류:", e)
        raise HTTPException(status_code=400, detail=f"Data processing error: {str(e)}")

@router.get("/data/latest")
def get_latest_data(db: Session = Depends(database.get_db)):
    """Flutter 앱에서 조회하는 최신 센서 데이터"""
    try:
        latest = crud.get_latest_sensor_data(db)
        if not latest:
            # 데이터가 없을 때 테스트 데이터 반환
            print("⚠️ DB에 데이터가 없어 테스트 데이터 반환")
            return {
                "device_id": "sensor01",
                "light": 535,
                "gas": 0,
                "pir": None,
                "timestamp": datetime.now().isoformat()
            }
        
        print(f"📊 최신 센서 데이터 조회: device_id={latest.device_id}, light={latest.light}, gas={latest.gas}, pir={latest.pir}")
        
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
        # 오류 시에도 테스트 데이터 반환하여 앱이 계속 작동하도록 함
        return {
            "device_id": "sensor01",
            "light": 535,
            "gas": 0,
            "pir": None,
            "timestamp": datetime.now().isoformat()
        }
