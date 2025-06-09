# from sqlalchemy.orm import Session
# import models, schemas
# from passlib.context import CryptContext
# from jose import jwt
# from datetime import datetime, timedelta

# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
# SECRET_KEY = "your-secret-key"
# ALGORITHM = "HS256"
# ACCESS_TOKEN_EXPIRE_MINUTES = 30

# def get_password_hash(password):
#     return pwd_context.hash(password)

# def verify_password(plain_password, hashed_password):
#     return pwd_context.verify(plain_password, hashed_password)

# def get_user_by_username(db: Session, username: str):
#     return db.query(models.User).filter(models.User.username == username).first()

# def create_user(db: Session, user: schemas.UserCreate):
#     hashed_password = get_password_hash(user.password)
#     db_user = models.User(username=user.username, email=user.email, hashed_password=hashed_password)
#     db.add(db_user)
#     db.commit()
#     db.refresh(db_user)
#     return db_user

# def authenticate_user(db: Session, username: str, password: str):
#     user = get_user_by_username(db, username)
#     if not user or not verify_password(password, user.hashed_password):
#         return False
#     return user

# def create_access_token(data: dict, expires_delta: timedelta = None):
#     to_encode = data.copy()
#     if expires_delta:
#         expire = datetime.utcnow() + expires_delta
#     else:
#         expire = datetime.utcnow() + timedelta(minutes=15)
#     to_encode.update({"exp": expire})
#     return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# from sqlalchemy.orm import Session
# from . import models, schemas

# def save_sensor_data(db: Session, data: schemas.SensorDataCreate):
#     entry = models.SensorData(**data.dict())
#     db.add(entry)
#     db.commit()
#     db.refresh(entry)
#     return entry

# def get_latest_sensor_data(db: Session):
#     return db.query(models.SensorData).order_by(models.SensorData.timestamp.desc()).first()


# from sqlalchemy.orm import Session
# from . import models, schemas
# from datetime import datetime

# def save_sensor_data(db: Session, sensor_data: schemas.SensorDataCreate):
#     """센서 데이터를 데이터베이스에 저장"""
#     db_sensor = models.SensorData(
#         device_id=sensor_data.device_id,
#         light=sensor_data.light,
#         gas=sensor_data.gas,
#         pir=sensor_data.pir,
#         timestamp=datetime.now()
#     )
#     db.add(db_sensor)
#     db.commit()
#     db.refresh(db_sensor)
#     return db_sensor

# def get_latest_sensor_data(db: Session):
#     """최신 센서 데이터 조회"""
#     return db.query(models.SensorData).order_by(models.SensorData.timestamp.desc()).first()

from sqlalchemy.orm import Session
import models, schemas  # 절대 import
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def create_user(db: Session, user: schemas.UserCreate):
    hashed_password = get_password_hash(user.password)
    db_user = models.User(username=user.username, email=user.email, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def authenticate_user(db: Session, username: str, password: str):
    user = get_user_by_username(db, username)
    if not user or not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def save_sensor_data(db: Session, sensor_data: schemas.SensorDataCreate):
    """센서 데이터를 데이터베이스에 저장"""
    db_sensor = models.SensorData(
        device_id=sensor_data.device_id,
        light=sensor_data.light,
        gas=sensor_data.gas,
        pir=sensor_data.pir,
        timestamp=datetime.now()
    )
    db.add(db_sensor)
    db.commit()
    db.refresh(db_sensor)
    return db_sensor

def get_latest_sensor_data(db: Session):
    """최신 센서 데이터 조회"""
    return db.query(models.SensorData).order_by(models.SensorData.timestamp.desc()).first()