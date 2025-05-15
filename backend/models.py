from sqlalchemy import Column, Integer, String
from database import Base
from sqlalchemy import Column, Integer, String, Float, DateTime
import datetime
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(100), nullable=False)

from sqlalchemy import Column, Integer, String, Float, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()


class Weather(Base):
    __tablename__ = "weather"

    id = Column(Integer, primary_key=True)
    location_code = Column(String(50))             # ✅
    location_name = Column(String(100))            # ✅
    temperature = Column(Float)
    humidity = Column(Float)
    wind_speed = Column(Float)
    wind_direction = Column(String(20))            # ✅
    precipitation = Column(Float)
    sky_condition = Column(String(100))            # ✅
    recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class AirQuality(Base):
    __tablename__ = "air_quality"

    id = Column(Integer, primary_key=True)
    location_code = Column(String(50))
    location_name = Column(String(100))
    pm10 = Column(Float)
    pm25 = Column(Float)  # ❗ DB에는 아직 없음
    air_quality_index = Column(String(20))
    o3 = Column(Float)
    no2 = Column(Float)
    co = Column(Float)
    so2 = Column(Float)
    recorded_at = Column(DateTime, default=datetime.datetime.utcnow)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
