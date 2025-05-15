from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from sqlalchemy.orm import Session
from .database import SessionLocal
from .services.weather_service import WeatherService
from .services.dust_service import DustService
from .config import settings
import asyncio

weather_service = WeatherService()
dust_service = DustService()

async def fetch_and_save_data():
    """날씨와 미세먼지 데이터를 가져와 DB에 저장하는 작업"""
    locations = [
        '60,127', '61,125', '62,126', '92,131', '73,127',
        '63,89', '68,87', '69,106', '67,100', '76,88',
        '89,90', '98,76', '91,106', '80,70', '58,64', '63,56'
    ]
    #  '60,127', '61,125', '62,126', '92,131', '73,127',
    #     '63,89', '68,87', '69,106', '67,100', '76,88',
    #     '89,90', '98,76', '91,106', '80,70', '58,64', '63,56'
    # ]
    
    db = SessionLocal()
    try:
        for location in locations:
            # 날씨 데이터
            weather_data = await weather_service.fetch_weather_data(location)
            if weather_data:
                await weather_service.save_weather_data(db, weather_data)
                print(f"{location} 날씨 데이터 저장 완료")
            
            dust_data = await dust_service.fetch_dust_data(location)
            if dust_data:
                await dust_service.save_dust_data(db, dust_data)
                print(f"{location} 미세먼지 데이터 저장 완료")
                
    except Exception as e:
        print(f"데이터 수집 중 오류 발생: {e}")
    finally:
        db.close()


def start_scheduler():
    """스케줄러 시작"""
    scheduler = AsyncIOScheduler()
    
    # 설정된 간격(초)마다 데이터 수집 작업 실행
    scheduler.add_job(
        fetch_and_save_data,
        IntervalTrigger(minutes=60),  # ✅ 10분마다 실행
        id='fetch_weather_dust_data',
        replace_existing=True
    )
    
    scheduler.start()
    print(f"스케줄러 시작됨 - {settings.SCHEDULER_INTERVAL}초 간격으로 데이터 수집")
    
    # 앱 시작 시 즉시 한 번 실행
    asyncio.create_task(fetch_and_save_data())
    
    return scheduler