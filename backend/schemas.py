from pydantic import BaseModel

class UserCreate(BaseModel):
    username: str
    email: str
    password: str

class UserOut(BaseModel):
    id: int
    username: str
    email: str

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str

from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class WeatherBase(BaseModel):
    location_code: str
    location_name: str
    temperature: float
    humidity: float
    wind_speed: float
    wind_direction: str
    precipitation: float
    sky_condition: str
    
class Weather(WeatherBase):
    id: int
    recorded_at: datetime
    created_at: datetime
    
    class Config:
        orm_mode = True

class AirQualityBase(BaseModel):
    location_code: str
    location_name: str
    pm10: float
    pm25: float
    air_quality_index: str
    
class AirQuality(AirQualityBase):
    id: int
    recorded_at: datetime
    created_at: datetime
    
    class Config:
        orm_mode = True

class WeatherResponse(BaseModel):
    weather: Weather
    air_quality: Optional[AirQuality] = None