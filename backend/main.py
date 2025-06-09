from api import iot
from api import fetch, weather, dust
from api.chatGPT_API import callChatGPT
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import SessionLocal, engine
from .api import fetch
from jose import JWTError, jwt
from datetime import timedelta
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
from .api import weather, dust
from .models import Base
from .database import engine
from .scheduler import start_scheduler
from . import models, schemas, crud

from fastapi import APIRouter
import requests
import json
from api.chatGPT_API import callChatGPT
print("🧮🧮🧮🧮🧮 I'm in main.py 🧮🧮🧮🧮🧮")

# FastAPI 앱 초기화
app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# DB 모델 초기화
models.Base.metadata.create_all(bind=engine)

# 라우터 객체 생성
router = APIRouter()

# 라즈베리파이 명령 수신 URL
RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"

# DB 세션 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 회원가입
@app.post("/signup", response_model=schemas.UserOut)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    return crud.create_user(db, user)

# 로그인
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

# 사용자 정보 가져오기
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

# 명령 수신 테스트용
@app.post("/receive-cmd")
def receive_cmd(data: dict):
    print(data)
    return {"status": "received"}

# 라즈베리파이 명령 전송 공통 함수
def send_window_command(action: str):
    try:
        res = requests.post(
            RASPBERRY_PI_URL,
            json={"action": action.upper()},
            headers={"Content-Type": "application/json"}
        )
        print(f"✅ 라즈베리 응답: {res.status_code}, {res.text}")

        if "application/json" in res.headers.get("Content-Type", ""):
            return {"status": "success", "raspberry_response": res.json()}
        else:
            return {"status": "error", "message": "응답이 JSON이 아님", "body": res.text}

    except Exception as e:
        print(f"❌ 명령 전송 에러: {e}")
        return {"status": "error", "message": str(e)}

from fastapi import Form
# ChatGPT 명령 처리 라우트
@app.post("/iot/chat-command")
def process_chat_command(text: str = Form(...)):
    print("📨 /iot/chat-command 호출됨")
    try:
        gpt_response = callChatGPT(text)
        print(f"[GPT 응답 원문]: {gpt_response}")
        parsed = json.loads(gpt_response)
        action = parsed.get("action")
        message = parsed.get("message")

        if action == "open":
            raspberry_result = send_window_command("OPEN")
        elif action == "close":
            raspberry_result = send_window_command("CLOSE")
        else:
            return {"action": action, "message": message}

        return {
            "action": action,
            "message": message,
            "raspberry_result": raspberry_result
        }

    except json.JSONDecodeError:
        return {"error": "응답 파싱 실패", "raw": gpt_response}
    except Exception as e:
        print(f"[ERROR] ChatGPT 호출 실패: {e}")
        return {"error": str(e)}


# 기존 라우트들도 유지
@router.post("/send/open")
def send_open_command():
    return send_window_command("OPEN")

@router.post("/send/close")
def send_close_command():
    return send_window_command("CLOSE")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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

# 스케줄러 설정
@app.on_event("startup")
async def startup_event():
    app.state.scheduler = start_scheduler()

@app.on_event("shutdown")
async def shutdown_event():
    app.state.scheduler.shutdown()

# 루트 테스트
@app.get("/")
def read_root():
    return {"message": "날씨 & 미세먼지 API 서버가 실행 중입니다."}

# 실행
if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
