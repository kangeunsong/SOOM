# # from sqlalchemy import create_engine
# # from sqlalchemy.ext.declarative import declarative_base
# # from sqlalchemy.orm import sessionmaker


# # SQLALCHEMY_DATABASE_URL = "mysql+pymysql://myuser:mypass@localhost:3306/mydb"


# # engine = create_engine(SQLALCHEMY_DATABASE_URL)
# # SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
# # Base = declarative_base()


# # def get_db():
# #     db = SessionLocal()
# #     try:
# #         yield db
# #     finally:
# #         db.close()

# import os
# from sqlalchemy import create_engine
# from sqlalchemy.ext.declarative import declarative_base
# from sqlalchemy.orm import sessionmaker
# from dotenv import load_dotenv

# # .env 파일 로드
# load_dotenv()

# # 환경 변수에서 DB 접속 정보 불러오기
# DB_USER = os.getenv("DB_USER")
# DB_PASSWORD = os.getenv("DB_PASSWORD")
# DB_HOST = os.getenv("DB_HOST")
# DB_PORT = os.getenv("DB_PORT")
# DB_NAME = os.getenv("DB_NAME")

# # SQLAlchemy 연결 URL 구성
# SQLALCHEMY_DATABASE_URL = (
#     f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
# )

# # DB 엔진 생성
# engine = create_engine(SQLALCHEMY_DATABASE_URL)

# # 세션 생성 함수 정의
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# # 모델 선언용 베이스 클래스
# Base = declarative_base()

# # 세션을 생성해주는 Dependency 함수
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()


from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLite 데이터베이스 사용 (파일로 저장됨)
SQLALCHEMY_DATABASE_URL = "sqlite:///./soom.db"

# DB 엔진 생성
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, 
    connect_args={"check_same_thread": False}  # SQLite 전용 설정
)

# 세션 생성 함수 정의
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 모델 선언용 베이스 클래스
Base = declarative_base()

# 세션을 생성해주는 Dependency 함수
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

print("✅ SQLite 데이터베이스 설정 완료: ./soom.db")