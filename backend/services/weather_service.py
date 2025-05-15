import requests
import urllib.parse
import datetime
from sqlalchemy.orm import Session
from..models import Weather
from ..config import settings

class WeatherService:
    def __init__(self):
        self.api_key = settings.WEATHER_API_KEY
        
    async def fetch_weather_data(self, location_code):
        """공공데이터 포털 날씨 API 호출"""
        url_base = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"

        now = datetime.datetime.now()

        # ✅ base_time을 가장 가까운 30분 단위로 내림
        if now.minute < 30:
            rounded = now.replace(minute=0, second=0, microsecond=0)
        else:
            rounded = now.replace(minute=30, second=0, microsecond=0)

        base_date = rounded.strftime("%Y%m%d")
        base_time = rounded.strftime("%H%M")

        nx, ny = location_code.split(',')

        url = (
            f"{url_base}"
            f"?serviceKey={self.api_key}"
            f"&numOfRows=100"
            f"&pageNo=1"
            f"&dataType=JSON"
            f"&base_date={base_date}"
            f"&base_time={base_time}"
            f"&nx={nx}"
            f"&ny={ny}"
        )

        try:
            response = requests.get(url)
            print("▶ 실제 요청된 URL:", response.url)
            print("▶ 응답 상태코드:", response.status_code)
            print("▶ 응답 내용:", response.text[:300])
            data = response.json()
            
            if response.status_code == 200 and data.get('response', {}).get('header', {}).get('resultCode') == '00':
                items = data.get('response', {}).get('body', {}).get('items', {}).get('item', [])
                return self._parse_weather_data(items, location_code)
            else:
                print(f"API 호출 실패: {data}")
                return None
        except Exception as e:
            print(f"날씨 데이터 가져오기 에러: {e}")
            return None

    def _parse_weather_data(self, items, location_code):
        """API 응답 데이터 파싱"""
        result = {
            'location_code': location_code,
            'location_name': self._get_location_name(location_code),
            'temperature': None,
            'humidity': None,
            'wind_speed': None,
            'wind_direction': None,
            'precipitation': None,
            'sky_condition': None,
            'recorded_at': datetime.datetime.now()
        }
        
        for item in items:
            category = item.get('category')
            value = item.get('obsrValue')
            
            if category == 'T1H':  # 기온
                result['temperature'] = float(value)
            elif category == 'REH':  # 습도
                result['humidity'] = float(value)
            elif category == 'WSD':  # 풍속
                result['wind_speed'] = float(value)
            elif category == 'VEC':  # 풍향
                result['wind_direction'] = self._convert_wind_direction(float(value))
            elif category == 'RN1':  # 1시간 강수량
                result['precipitation'] = float(value)
            elif category == 'PTY':  # 강수형태
                result['sky_condition'] = self._convert_precipitation_type(value)
                
        return result
    def _get_location_name(self, location_code):
            """위치 코드를 이름으로 변환"""
            # 확장된 위치 매핑
            location_mapping = {
                # 수도권
                '60,127': '서울',
                '55,124': '인천',
                '61,125': '경기북부',
                '62,120': '경기북부',
                '62,126': '경기남부',
                '61,131': '경기남부',
                '65,130': '경기남부',
                
   
                '73,134': '원주',
                '84,135': '강원영동',
                '92,131': '강원영동',
                '73,127': '강원영서',
                
                '63,89': '대전',
                '68,87': '세종',
                '68,107': '충남',
                '69,106': '충남',
                '67,100': '충남',
                '68,83': '충북',
                '76,88': '충북',
                
                '89,90': '대구',
                '98,76': '부산',
                '91,77': '울산',
                '91,106': '경북',
                '80,70': '경남',
                '87,68': '경남',
                '81,75': '경남',
                '102,84': '경북',
                
                '51,67': '광주',
                '59,74': '전북',
                '56,71': '전북',
                '58,64': '전북',
                '56,53': '전남',
                '63,56': '전남',
                
                '52,38': '제주'
            }
            return location_mapping.get(location_code, '알 수 없는 위치')
            
   
    def _convert_wind_direction(self, direction):
        """풍향 각도를 방향으로 변환"""
        directions = ['북', '북동', '동', '남동', '남', '남서', '서', '북서']
        idx = round(direction / 45) % 8
        return directions[idx]
    
    def _convert_precipitation_type(self, type_code):
        """강수 형태 코드를 텍스트로 변환"""
        types = {
            '0': '맑음',
            '1': '비',
            '2': '비/눈',
            '3': '눈',
            '4': '소나기'
        }
        return types.get(type_code, '알 수 없음')
    
    async def save_weather_data(self, db: Session, weather_data):
        """날씨 데이터를 데이터베이스에 저장"""
        if not weather_data:
            return None
            
        db_weather = Weather(
            location_code=weather_data['location_code'],
            location_name=weather_data['location_name'],
            temperature=weather_data['temperature'],
            humidity=weather_data['humidity'],
            wind_speed=weather_data['wind_speed'],
            wind_direction=weather_data['wind_direction'],
            precipitation=weather_data['precipitation'],
            sky_condition=weather_data['sky_condition'],
            recorded_at=weather_data['recorded_at']
        )
        
        db.add(db_weather)
        db.commit()
        db.refresh(db_weather)
        return db_weather


