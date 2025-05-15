import requests
import datetime
from sqlalchemy.orm import Session
from models import AirQuality
from config import settings
BUSAN_STATIONS = ["연제구", "중구", "사상구", "해운대구", "부산진구", "남구", "동구", "사하구"]

class DustService:
    def __init__(self):
        self.api_key = settings.DUST_API_KEY
    
    def is_station_valid_and_available(self, station_name: str) -> bool:
        """측정소명이 유효하고 현재 실시간 데이터 수집이 가능한지 확인"""
        url = (
            "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
            f"?serviceKey={self.api_key}"
        )

        params = {
            'returnType': 'json',
            'numOfRows': '1',
            'pageNo': '1',
            'stationName': station_name,
            'dataTerm': 'DAILY',
            'ver': '1.0'
        }

        try:
            response = requests.get(url, params=params)
            if response.status_code != 200:
                print(f"❌ HTTP 오류: {response.status_code}")
                return False

            data = response.json()

            result_code = data.get("response", {}).get("header", {}).get("resultCode", "")
            items = data.get("response", {}).get("body", {}).get("items", [])

            if result_code == "00" and items:
                return True
            else:
                print(f"⚠️ API 응답 실패 또는 데이터 없음. 측정소명: {station_name}")
                return False
        except Exception as e:
            print(f"⚠️ 예외 발생: {e}")
            return False
    def get_available_station_in_busan(self) -> str:
        """부산에서 사용 가능한 측정소를 순차적으로 확인하고 하나 리턴"""
        for station in BUSAN_STATIONS:
            if self.is_station_valid_and_available(station):
                print(f"✅ 대체 가능 측정소 사용: {station}")
                return station
        print("❌ 부산 지역에서 사용 가능한 측정소 없음")
        return None

        
    async def fetch_dust_data(self, location_code):
        """공공데이터 포털 미세먼지 API 호출"""
        url = (
            "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
            f"?serviceKey={self.api_key}"
        )
        station_name = self._get_station_name(location_code)
        if not self.is_station_valid_and_available(station_name):
            print(f"⚠️ 기본 측정소 '{station_name}'에서 데이터 없음, 대체 측정소 시도")
            station_name = self.get_available_station_in_busan()
            if not station_name:
                return None  # 대체 실패 시 종료


        params = {
            'returnType': 'json',
            'numOfRows': '1',
            'pageNo': '1',
            'stationName': self._get_station_name(location_code),
            'dataTerm': 'DAILY',
            'ver': '1.0'
        }

        response = requests.get(url, params=params)

        try:
            response = requests.get(url, params=params)
            print("▶ 실제 요청된 URL:", response.url)
            print("▶ 응답 상태코드:", response.status_code)
            print("▶ 응답 내용:", response.text[:300])

            if response.status_code != 200:
                print(f"❌ HTTP 오류: {response.status_code}")
                print(f"❌ 응답 내용: {response.text}")
                return None

            try:
                data = response.json()
            except ValueError as ve:
                # print("❌ JSON 파싱 실패. 응답 내용:", response.text)
                return None

            # 결과 코드 확인
            if data.get('response', {}).get('header', {}).get('resultCode') == '00':
                items = data.get('response', {}).get('body', {}).get('items', [])
                if items:
                    return self._parse_dust_data(items[0], location_code)
                else:
                    print("❌ 아이템 없음")
            else:
                print(f"❌ API 실패 응답: {data}")
        except Exception as e:
            print(f"미세먼지 데이터 가져오기 에러: {e}")
    
    def _get_station_name(self, location_code):
        """위치 코드를 측정소 이름으로 변환"""
        station_mapping = {
            '60,127': '중구',       # 서울
            '55,124': '연희동',     # 인천
            '65,130': '수지',       # 경기남부
            '73,134': '원주',       # 강원
            '84,135': '강릉',       # 강원영동
            '68,107': '서산',       # 충남
            '68,83': '청주',        # 충북
            '89,90': '신암동',      # 대구
            '98,76': '중구',      # 부산
            '91,77': '울산',        # 울산
            '81,75': '창원',        # 경남
            '102,84': '경주시',     # 경북
            '51,67': '광주',        # 광주
            '59,74': '전주시',      # 전북
            '56,53': '목포시',      # 전남
            '52,38': '제주시',      # 제주
        }
        return station_mapping.get(location_code, '종로구')  
    def _parse_dust_data(self, item, location_code):
        """API 응답 데이터 파싱"""
        return {
            'location_code': location_code,
            'location_name': self._get_location_name(location_code),
            'pm10': float(item.get('pm10Value', 0)),
            'pm25': float(item.get('pm25Value', 0)),
            'air_quality_index': self._calculate_aqi(
                float(item.get('pm10Value', 0)), 
                float(item.get('pm25Value', 0))
            ),
            'recorded_at': datetime.datetime.now()
        }
    
    
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
                '68,87': '세종' ,
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
    def _calculate_aqi(self, pm10, pm25):
        """미세먼지 수치를 공기질 지수로 변환"""
        # 간단한 예시 로직
        if pm10 <= 30 and pm25 <= 15:
            return '좋음'
        elif pm10 <= 80 and pm25 <= 35:
            return '보통'
        elif pm10 <= 150 and pm25 <= 75:
            return '나쁨'
        else:
            return '매우 나쁨'
    
    async def save_dust_data(self, db: Session, dust_data):
        """미세먼지 데이터를 데이터베이스에 저장"""
        if not dust_data:
            return None
            
        db_air_quality = AirQuality(
            location_code=dust_data['location_code'],
            location_name=dust_data['location_name'],
            pm10=dust_data['pm10'],
            pm25=dust_data['pm25'],
            air_quality_index=dust_data['air_quality_index'],
            recorded_at=dust_data['recorded_at']
        )
        
        db.add(db_air_quality)
        db.commit()
        db.refresh(db_air_quality)
        return db_air_quality