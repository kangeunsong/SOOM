# from sqlalchemy import Column, Integer, String
# from database import Base
# from sqlalchemy import Column, Integer, String, Float, DateTime
# import datetime


# class User(Base):
#     __tablename__ = "users"
#     id = Column(Integer, primary_key=True, index=True)
#     username = Column(String(50), unique=True, index=True, nullable=False)
#     email = Column(String(100), unique=True, index=True, nullable=False)
#     hashed_password = Column(String(100), nullable=False)

# from sqlalchemy import Column, Integer, String, Float, DateTime, create_engine
# from sqlalchemy.ext.declarative import declarative_base
# import datetime

# Base = declarative_base()


# class Weather(Base):
#     __tablename__ = "weather"

#     id = Column(Integer, primary_key=True)
#     location_code = Column(String(50))             # ✅
#     location_name = Column(String(100))            # ✅
#     temperature = Column(Float)
#     humidity = Column(Float)
#     wind_speed = Column(Float)
#     wind_direction = Column(String(20))            # ✅
#     precipitation = Column(Float)
#     sky_condition = Column(String(100))            # ✅
#     recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
#     created_at = Column(DateTime, default=datetime.datetime.utcnow)

# class AirQuality(Base):
#     __tablename__ = "air_quality"

#     id = Column(Integer, primary_key=True)
#     location_code = Column(String(50))
#     location_name = Column(String(100))
#     pm10 = Column(Float)
#     pm25 = Column(Float)  # ❗ DB에는 아직 없음
#     air_quality_index = Column(String(20))
#     o3 = Column(Float)
#     no2 = Column(Float)
#     co = Column(Float)
#     so2 = Column(Float)
#     recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
#     created_at = Column(DateTime, default=datetime.datetime.utcnow)
# from sqlalchemy import Column, Integer, String, Float, DateTime
# from sqlalchemy.sql import func
# from .database import Base
# class SensorData(Base):
#     __tablename__ = "sensor_data"
#     __table_args__ = {'extend_existing': True}  # 기존 테이블 확장 허용
    
#     id = Column(Integer, primary_key=True, index=True)
#     device_id = Column(String(50), index=True)
#     light = Column(Integer, nullable=True)      # 조도 센서
#     gas = Column(Integer, nullable=True)        # 가스 센서  
#     pir = Column(Integer, nullable=True)        # 움직임 센서
#     timestamp = Column(DateTime, default=func.now())  # 타임스탬프

from sqlalchemy import Column, Integer, String, Float, DateTime
from sqlalchemy.sql import func
from database import Base  # 상대 import 제거
import datetime

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(100), nullable=False)

class Weather(Base):
    __tablename__ = "weather"

    id = Column(Integer, primary_key=True)
    location_code = Column(String(50))
    location_name = Column(String(100))
    temperature = Column(Float)
    humidity = Column(Float)
    wind_speed = Column(Float)
    wind_direction = Column(String(20))
    precipitation = Column(Float)
    sky_condition = Column(String(100))
    recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class AirQuality(Base):
    __tablename__ = "air_quality"

    id = Column(Integer, primary_key=True)
    location_code = Column(String(50))
    location_name = Column(String(100))
    pm10 = Column(Float)
    pm25 = Column(Float)
    air_quality_index = Column(String(20))
    o3 = Column(Float)
    no2 = Column(Float)
    co = Column(Float)
    so2 = Column(Float)
    recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class SensorData(Base):
    __tablename__ = "sensor_data"
    __table_args__ = {'extend_existing': True}
    
    id = Column(Integer, primary_key=True, index=True)
    device_id = Column(String(50), index=True)
    light = Column(Integer, nullable=True)      # 조도 센서
    gas = Column(Integer, nullable=True)        # 가스 센서  
    pir = Column(Integer, nullable=True)        # 움직임 센서
    timestamp = Column(DateTime, default=func.now())  # 타임스탬프