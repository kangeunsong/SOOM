from backend.api import iot
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import SessionLocal, engine
from .api import fetch  # ← 추가
from jose import JWTError, jwt
from datetime import timedelta
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from .api import weather, dust
from .models import Base
from .database import engine
from .scheduler import start_scheduler
from .import models
from .import schemas
from .import crud

models.Base.metadata.create_all(bind=engine)

app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
print("📌 등록된 라우트 목록:")
for route in app.router.routes:
    print(f"{route.path} → {route.name}")
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/signup", response_model=schemas.UserOut)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    return crud.create_user(db, user)


@app.post("/token", response_model=schemas.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")
    access_token_expires = timedelta(minutes=crud.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = crud.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=schemas.UserOut)
def read_users_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
    )
    try:
        payload = jwt.decode(token, crud.SECRET_KEY, algorithms=[crud.ALGORITHM])
        username = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = crud.get_user_by_username(db, username)
    if user is None:
        raise credentials_exception
    return user
@app.get("/latest")
def get_latest_data(db: Session = Depends(get_db)):
    data = db.query(SensorData).order_by(SensorData.timestamp.desc()).first()
    return {
        "device_id": data.device_id,
        "temperature": data.temperature,
        "humidity": data.humidity,
        "timestamp": data.timestamp
    }
from fastapi import APIRouter
import requests

router = APIRouter()

RASPBERRY_PI_URL = "https://a4a6-113-198-180-236.ngrok-free.app/receive-cmd"  # 라즈베리 파이 주소

@router.post("/send/open")
def send_open_command():
    print("✅ [DEBUG] /send/open 라우터에 도달함")
    try:
        res = requests.post(
            RASPBERRY_PI_URL,
            json={"action": "OPEN"},
            headers={"Content-Type": "application/json"}
        )
        print(f"✅ [DEBUG] 라즈베리 응답: {res.status_code}, {res.text}")
        return {"status": "success", "raspberry_response": res.json()}
    except Exception as e:
        print(f"❌ [DEBUG] 오류 발생: {e}")
        return {"status": "error", "message": str(e)}

@router.post("/send/close")
def send_close_command():
    print("🔧 CLOSE 명령 전송 시도 중")
    try:
        res = requests.post(
            RASPBERRY_PI_URL,
            json={"action": "CLOSE"},
            headers={"Content-Type": "application/json"}
        )
        print(f"✅ 응답 수신: {res.status_code}, {res.text}")
        return {"status": "success", "raspberry_response": res.json()}
    except Exception as e:
        print(f"❌ 에러 발생: {e}")
        return {"status": "error", "message": str(e)}
# 데이터베이스 테이블 생성
Base.metadata.create_all(bind=engine)


# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시 구체적인 도메인으로 제한해야 함
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(router, prefix="/iot")
app.include_router(weather.router)
app.include_router(dust.router)
app.include_router(fetch.router)
app.include_router(iot.router, prefix="/iot")
# app.include_router(iot.router)  # ← 추가
@app.on_event("startup")
async def startup_event():
    """애플리케이션 시작 시 스케줄러 시작"""
    app.state.scheduler = start_scheduler()

@app.on_event("shutdown")
async def shutdown_event():
    """애플리케이션 종료 시 스케줄러 종료"""
    app.state.scheduler.shutdown()

@app.get("/")
def read_root():
    return {"message": "날씨 & 미세먼지 API 서버가 실행 중입니다."}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

