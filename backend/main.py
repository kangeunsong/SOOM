# # main.py 파일의 상단 import 부분을 다음과 같이 수정

# # 기존 코드:
# # from backend.api import iot
# # from .database import SessionLocal, engine
# # from .api import fetch
# # from .models import Base
# # from .database import engine
# # from .scheduler import start_scheduler
# # from .import models
# # from .import schemas
# # from .import crud

# # 수정된 코드:
# from api import iot
# from database import SessionLocal, engine
# from api import fetch
# from models import Base
# from database import engine
# from scheduler import start_scheduler
# import models
# import schemas
# import crud
# from chatGPT import callChatGPT  # ChatGPT 함수 import 추가

# from fastapi import FastAPI, Depends, HTTPException, status, Form
# from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
# from sqlalchemy.orm import Session
# from jose import JWTError, jwt
# from datetime import timedelta
# from fastapi.middleware.cors import CORSMiddleware
# import uvicorn
# from api import weather, dust
# import json
# import requests

# models.Base.metadata.create_all(bind=engine)

# app = FastAPI()
# oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# print("📌 등록된 라우트 목록:")
# for route in app.router.routes:
#     print(f"{route.path} → {route.name}")

# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

# @app.post("/signup", response_model=schemas.UserOut)
# def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
#     db_user = crud.get_user_by_username(db, user.username)
#     if db_user:
#         raise HTTPException(status_code=400, detail="Username already registered")
#     return crud.create_user(db, user)

# @app.post("/token", response_model=schemas.Token)
# def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
#     user = crud.authenticate_user(db, form_data.username, form_data.password)
#     if not user:
#         raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect username or password")
#     access_token_expires = timedelta(minutes=crud.ACCESS_TOKEN_EXPIRE_MINUTES)
#     access_token = crud.create_access_token(
#         data={"sub": user.username}, expires_delta=access_token_expires
#     )
#     return {"access_token": access_token, "token_type": "bearer"}

# @app.get("/users/me", response_model=schemas.UserOut)
# def read_users_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
#     credentials_exception = HTTPException(
#         status_code=status.HTTP_401_UNAUTHORIZED,
#         detail="Could not validate credentials",
#     )
#     try:
#         payload = jwt.decode(token, crud.SECRET_KEY, algorithms=[crud.ALGORITHM])
#         username = payload.get("sub")
#         if username is None:
#             raise credentials_exception
#     except JWTError:
#         raise credentials_exception
#     user = crud.get_user_by_username(db, username)
#     if user is None:
#         raise credentials_exception
#     return user

# # ChatGPT 라우터 추가
# @app.post("/iot/chat-command")
# async def chat_command(text: str = Form(...)):
#     """Flutter 앱에서 텍스트 입력을 받아 ChatGPT로 처리하는 엔드포인트"""
#     try:
#         print(f"[DEBUG] 받은 텍스트: {text}")
        
#         # ChatGPT 호출
#         response = callChatGPT(text)
#         print(f"[DEBUG] ChatGPT 응답: {response}")
        
#         # JSON 파싱
#         try:
#             parsed = json.loads(response)
#             action = parsed.get("action", "none")
#             message = parsed.get("message", "응답을 처리할 수 없어요.")
            
#             # 창문 제어 액션 처리
#             RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"
            
#             if action == "open":
#                 print("[ACTION] 창문 열기 실행")
#                 try:
#                     res = requests.post(
#                         RASPBERRY_PI_URL,
#                         json={"action": "OPEN"},
#                         headers={"Content-Type": "application/json"}
#                     )
#                     print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#                 except Exception as e:
#                     print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
                    
#             elif action == "close":
#                 print("[ACTION] 창문 닫기 실행")
#                 try:
#                     res = requests.post(
#                         RASPBERRY_PI_URL,
#                         json={"action": "CLOSE"},
#                         headers={"Content-Type": "application/json"}
#                     )
#                     print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#                 except Exception as e:
#                     print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
            
#             return {"message": message, "action": action}
            
#         except json.JSONDecodeError:
#             print("[ERROR] ChatGPT 응답 JSON 파싱 실패")
#             return {"message": "죄송해요. 응답을 처리하는 중 오류가 발생했어요.", "action": "none"}
            
#     except Exception as e:
#         print(f"[ERROR] 전체 처리 오류: {e}")
#         return {"message": "서버 오류가 발생했어요. 다시 시도해주세요.", "action": "error"}

# # 기존 라우터들
# from fastapi import APIRouter

# router = APIRouter()
# RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"

# @router.post("/send/open")
# def send_open_command():
#     print("✅ [DEBUG] /send/open 라우터에 도달함")
#     try:
#         res = requests.post(
#             RASPBERRY_PI_URL,
#             json={"action": "OPEN"},
#             headers={"Content-Type": "application/json"}
#         )
#         print(f"✅ [DEBUG] 라즈베리 응답: {res.status_code}, {res.text}")

#         if "application/json" in res.headers.get("Content-Type", ""):
#             return {"status": "success", "raspberry_response": res.json()}
#         else:
#             return {"status": "error", "message": "응답이 JSON이 아님", "body": res.text}

#     except Exception as e:
#         print(f"❌ [DEBUG] 오류 발생: {e}")
#         return {"status": "error", "message": str(e)}

# @router.post("/send/close")
# def send_close_command():
#     print("🔧 CLOSE 명령 전송 시도 중")
#     try:
#         res = requests.post(
#             RASPBERRY_PI_URL,
#             json={"action": "CLOSE"},
#             headers={"Content-Type": "application/json"}
#         )
#         print(f"✅ 응답 수신: {res.status_code}, {res.text}")

#         if "application/json" in res.headers.get("Content-Type", ""):
#             return {"status": "success", "raspberry_response": res.json()}
#         else:
#             return {"status": "error", "message": "응답이 JSON이 아님", "body": res.text}

#     except Exception as e:
#         print(f"❌ 에러 발생: {e}")
#         return {"status": "error", "message": str(e)}

# # CORS 설정
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # 라우터 등록
# app.include_router(router, prefix="/iot")
# app.include_router(weather.router)
# app.include_router(dust.router)
# app.include_router(fetch.router)
# app.include_router(iot.router, prefix="/iot")

# @app.on_event("startup")
# async def startup_event():
#     """애플리케이션 시작 시 스케줄러 시작"""
#     app.state.scheduler = start_scheduler()

# @app.on_event("shutdown")
# async def shutdown_event():
#     """애플리케이션 종료 시 스케줄러 종료"""
#     app.state.scheduler.shutdown()

# @app.get("/")
# def read_root():
#     return {"message": "날씨 & 미세먼지 API 서버가 실행 중입니다."}

# if __name__ == "__main__":
#     uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

from api import iot
from database import SessionLocal, engine
# from api import fetch  # 임시 주석 처리
from models import Base
# from scheduler import start_scheduler  # 임시 주석 처리
import models
import schemas
import crud
from chatGPT import callChatGPT

from fastapi import FastAPI, Depends, HTTPException, status, Form
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from datetime import timedelta
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
# from api import weather, dust  # 임시 주석 처리
import json
import requests

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

# # ChatGPT 라우터 추가
# @app.post("/iot/chat-command")
# async def chat_command(text: str = Form(...)):
#     """Flutter 앱에서 텍스트 입력을 받아 ChatGPT로 처리하는 엔드포인트"""
#     try:
#         print(f"[DEBUG] 받은 텍스트: {text}")
        
#         # ChatGPT 호출
#         response = callChatGPT(text)
#         print(f"[DEBUG] ChatGPT 응답: {response}")
        
#         # JSON 파싱
#         try:
#             parsed = json.loads(response)
#             action = parsed.get("action", "none")
#             message = parsed.get("message", "응답을 처리할 수 없어요.")
            
#             # 창문 제어 액션 처리
#             RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"
            
#             if action == "open":
#                 print("[ACTION] 창문 열기 실행")
#                 try:
#                     res = requests.post(
#                         RASPBERRY_PI_URL,
#                         json={"action": "OPEN"},
#                         headers={"Content-Type": "application/json"}
#                     )
#                     print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#                 except Exception as e:
#                     print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
                    
#             elif action == "close":
#                 print("[ACTION] 창문 닫기 실행")
#                 try:
#                     res = requests.post(
#                         RASPBERRY_PI_URL,
#                         json={"action": "CLOSE"},
#                         headers={"Content-Type": "application/json"}
#                     )
#                     print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#                 except Exception as e:
#                     print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
            
#             return {"message": message, "action": action}
            
#         except json.JSONDecodeError:
#             print("[ERROR] ChatGPT 응답 JSON 파싱 실패")
#             return {"message": "죄송해요. 응답을 처리하는 중 오류가 발생했어요.", "action": "none"}
            
#     except Exception as e:
#         print(f"[ERROR] 전체 처리 오류: {e}")
#         return {"message": "서버 오류가 발생했어요. 다시 시도해주세요.", "action": "error"}

# ChatGPT 라우터를 임시로 이렇게 수정
# ChatGPT 라우터 - 한글 인코딩 문제 해결
# @app.post("/iot/chat-command")
# async def chat_command(text: str = Form(...)):
#     """Flutter 앱에서 텍스트 입력을 받아 처리하는 엔드포인트"""
#     try:
#         # 한글 인코딩 문제 해결
#         try:
#             # UTF-8로 다시 디코딩 시도
#             if isinstance(text, str):
#                 # 이미 문자열이면 그대로 사용
#                 decoded_text = text
#             else:
#                 decoded_text = text.decode('utf-8')
#         except:
#             decoded_text = text
        
#         print(f"[DEBUG] 받은 텍스트: '{decoded_text}'")
#         print(f"[DEBUG] 텍스트 길이: {len(decoded_text)}")
#         print(f"[DEBUG] 텍스트 바이트: {decoded_text.encode('utf-8')}")
        
#         # 더 유연한 패턴 매칭
#         text_lower = decoded_text.lower()
        
#         # 각 문자별로 확인 (인코딩 문제 대비)
#         has_hello = any(word in decoded_text for word in ["안녕", "하이", "수미", "hello", "hi"])
#         has_open = any(word in decoded_text for word in ["창문", "열어", "환기", "open", "켜"])
#         has_close = any(word in decoded_text for word in ["닫아", "닫기", "끄기", "close", "stop"])
        
#         print(f"[DEBUG] 패턴 검사: hello={has_hello}, open={has_open}, close={has_close}")
        
#         if has_hello:
#             action = "greet"
#             message = "안녕하세요! 저는 수미예요. 무엇을 도와드릴까요?"
#         elif has_open:
#             action = "open"
#             message = "네, 창문을 열어드리겠습니다!"
#         elif has_close:
#             action = "close"
#             message = "네, 창문을 닫아드리겠습니다!"
#         else:
#             action = "none"
#             message = f"말씀해주신 내용을 이해했어요. 창문 제어나 환기에 대해 도움을 드릴 수 있습니다!"
        
#         print(f"[DEBUG] 최종 응답: action={action}, message={message}")
        
#         # 창문 제어 액션 처리
#         RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"
        
#         if action == "open":
#             print("[ACTION] 창문 열기 실행")
#             try:
#                 res = requests.post(
#                     RASPBERRY_PI_URL,
#                     json={"action": "OPEN"},
#                     headers={"Content-Type": "application/json"},
#                     timeout=5
#                 )
#                 print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#             except Exception as e:
#                 print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
                
#         elif action == "close":
#             print("[ACTION] 창문 닫기 실행")
#             try:
#                 res = requests.post(
#                     RASPBERRY_PI_URL,
#                     json={"action": "CLOSE"},
#                     headers={"Content-Type": "application/json"},
#                     timeout=5
#                 )
#                 print(f"[DEBUG] 라즈베리파이 응답: {res.status_code}")
#             except Exception as e:
#                 print(f"[ERROR] 라즈베리파이 통신 오류: {e}")
        
#         return {"message": message, "action": action}
        
#     except Exception as e:
#         print(f"[ERROR] 전체 처리 오류: {e}")
#         import traceback
#         print(f"[ERROR] 상세 오류: {traceback.format_exc()}")
#         return {"message": "서버 오류가 발생했어요. 다시 시도해주세요.", "action": "error"}

@app.post("/iot/chat-command")
async def chat_command(text: str = Form(...)):
    """Flutter 앱에서 텍스트 입력을 받아 처리하는 엔드포인트"""
    try:
        print(f"[DEBUG] 원본 텍스트: '{text}'")
        print(f"[DEBUG] 텍스트 타입: {type(text)}")
        print(f"[DEBUG] 텍스트 repr: {repr(text)}")
        
        # 일단 모든 입력에 대해 고정 응답으로 테스트
        if "test" in text.lower():
            action = "greet"
            message = "테스트 성공했어요!"
        else:
            # 임시로 모든 요청을 창문 열기로 처리
            action = "open"
            message = "창문을 열어드리겠습니다! (테스트 중)"
        
        print(f"[DEBUG] 응답: action={action}, message={message}")
        
        # 라즈베리파이 통신 (일단 주석처리로 빠르게 테스트)
        # RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"
        # if action == "open":
        #     print("[ACTION] 창문 열기 실행")
        
        return {"message": message, "action": action}
        
    except Exception as e:
        print(f"[ERROR] 오류: {e}")
        import traceback
        traceback.print_exc()
        return {"message": "서버 오류가 발생했어요.", "action": "error"}

# 기존 라우터들
from fastapi import APIRouter

router = APIRouter()
RASPBERRY_PI_URL = "https://a402-113-198-180-138.ngrok-free.app/receive-cmd"

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

        if "application/json" in res.headers.get("Content-Type", ""):
            return {"status": "success", "raspberry_response": res.json()}
        else:
            return {"status": "error", "message": "응답이 JSON이 아님", "body": res.text}

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

        if "application/json" in res.headers.get("Content-Type", ""):
            return {"status": "success", "raspberry_response": res.json()}
        else:
            return {"status": "error", "message": "응답이 JSON이 아님", "body": res.text}

    except Exception as e:
        print(f"❌ 에러 발생: {e}")
        return {"status": "error", "message": str(e)}

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
# app.include_router(weather.router)  # 임시 주석 처리
# app.include_router(dust.router)     # 임시 주석 처리
# app.include_router(fetch.router)    # 임시 주석 처리
app.include_router(iot.router, prefix="/iot")

# 스케줄러 관련 부분 임시 주석 처리
# @app.on_event("startup")
# async def startup_event():
#     """애플리케이션 시작 시 스케줄러 시작"""
#     app.state.scheduler = start_scheduler()

# @app.on_event("shutdown")
# async def shutdown_event():
#     """애플리케이션 종료 시 스케줄러 종료"""
#     app.state.scheduler.shutdown()

@app.get("/")
def read_root():
    return {"message": "ChatGPT 연동 테스트 서버가 실행 중입니다."}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)