from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os

# ✅ 반드시 먼저 불러오기
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '.env'))

class Settings(BaseSettings):
    DATABASE_URL: str
    WEATHER_API_KEY: str
    DUST_API_KEY: str
    SCHEDULER_INTERVAL: int
    API_BASE_URL: str  # ✅ 이 줄 추가

    class Config:
        env_file = ".env"

settings = Settings()
