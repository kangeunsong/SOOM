
import os
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

load_dotenv()

class Settings(BaseSettings):
    DATABASE_URL: str
    WEATHER_API_KEY: str
    DUST_API_KEY: str
    SCHEDULER_INTERVAL: int

    class Config:
        env_file = ".env"

settings = Settings()
