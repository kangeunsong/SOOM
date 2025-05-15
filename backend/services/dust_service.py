# import requests
# import datetime
# from sqlalchemy.orm import Session
# from ..models import AirQuality
# from ..config import settings
# BUSAN_STATIONS = ["연제구", "중구", "사상구", "해운대구", "부산진구", "남구", "동구", "사하구"]

# class DustService:
#     def __init__(self):
#         self.api_key = settings.DUST_API_KEY
    
#     def is_station_valid_and_available(self, station_name: str) -> bool:
#         """측정소명이 유효하고 현재 실시간 데이터 수집이 가능한지 확인"""
#         url = (
#             "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
#             f"?serviceKey={self.api_key}"
#         )

#         params = {
#             'returnType': 'json',
#             'numOfRows': '1',
#             'pageNo': '1',
#             'stationName': station_name,
#             'dataTerm': 'DAILY',
#             'ver': '1.0'
#         }

#         try:
#             response = requests.get(url, params=params)
#             if response.status_code != 200:
#                 print(f"❌ HTTP 오류: {response.status_code}")
#                 return False

#             data = response.json()

#             result_code = data.get("response", {}).get("header", {}).get("resultCode", "")
#             items = data.get("response", {}).get("body", {}).get("items", [])

#             if result_code == "00" and items:
#                 return True
#             else:
#                 print(f"⚠️ API 응답 실패 또는 데이터 없음. 측정소명: {station_name}")
#                 return False
#         except Exception as e:
#             print(f"⚠️ 예외 발생: {e}")
#             return False
#     def get_available_station_in_busan(self) -> str:
#         """부산에서 사용 가능한 측정소를 순차적으로 확인하고 하나 리턴"""
#         for station in BUSAN_STATIONS:
#             if self.is_station_valid_and_available(station):
#                 print(f"✅ 대체 가능 측정소 사용: {station}")
#                 return station
#         print("❌ 부산 지역에서 사용 가능한 측정소 없음")
#         return None

        
#     async def fetch_dust_data(self, location_code):
#         """공공데이터 포털 미세먼지 API 호출"""
#         url = (
#             "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
#             f"?serviceKey={self.api_key}"
#         )
#         station_name = self._get_station_name(location_code)
#         if not self.is_station_valid_and_available(station_name):
#             print(f"⚠️ 기본 측정소 '{station_name}'에서 데이터 없음, 대체 측정소 시도")
#             station_name = self.get_available_station_in_busan()
#             if not station_name:
#                 return None  # 대체 실패 시 종료


#         params = {
#             'returnType': 'json',
#             'numOfRows': '1',
#             'pageNo': '1',
#             'stationName': self._get_station_name(location_code),
#             'dataTerm': 'DAILY',
#             'ver': '1.0'
#         }

#         response = requests.get(url, params=params)

#         try:
#             response = requests.get(url, params=params)
#             print("▶ 실제 요청된 URL:", response.url)
#             print("▶ 응답 상태코드:", response.status_code)
#             print("▶ 응답 내용:", response.text[:300])

#             if response.status_code != 200:
#                 print(f"❌ HTTP 오류: {response.status_code}")
#                 print(f"❌ 응답 내용: {response.text}")
#                 return None

#             try:
#                 data = response.json()
#             except ValueError as ve:
#                 # print("❌ JSON 파싱 실패. 응답 내용:", response.text)
#                 return None

#             # 결과 코드 확인
#             if data.get('response', {}).get('header', {}).get('resultCode') == '00':
#                 items = data.get('response', {}).get('body', {}).get('items', [])
#                 if items:
#                     return self._parse_dust_data(items[0], location_code)
#                 else:
#                     print("❌ 아이템 없음")
#             else:
#                 print(f"❌ API 실패 응답: {data}")
#         except Exception as e:
#             print(f"미세먼지 데이터 가져오기 에러: {e}")
    
#     def _get_station_name(self, location_code):
#         """위치 코드를 측정소 이름으로 변환"""
#         station_mapping = {
#             '60,127': '중구',       # 서울
#             '55,124': '연희동',     # 인천
#             '65,130': '수지',       # 경기남부
#             '73,134': '원주',       # 강원
#             '84,135': '강릉',       # 강원영동
#             '68,107': '서산',       # 충남
#             '68,83': '청주',        # 충북
#             '89,90': '신암동',      # 대구
#             '98,76': '중구',      # 부산
#             '91,77': '울산',        # 울산
#             '81,75': '창원',        # 경남
#             '102,84': '경주시',     # 경북
#             '51,67': '광주',        # 광주
#             '59,74': '전주시',      # 전북
#             '56,53': '목포시',      # 전남
#             '52,38': '제주시',      # 제주
#         }
#         return station_mapping.get(location_code, '종로구')  
#     def _parse_dust_data(self, item, location_code):
#         """API 응답 데이터 파싱"""
#         return {
#             'location_code': location_code,
#             'location_name': self._get_location_name(location_code),
#             'pm10': float(item.get('pm10Value', 0)),
#             'pm25': float(item.get('pm25Value', 0)),
#             'air_quality_index': self._calculate_aqi(
#                 float(item.get('pm10Value', 0)), 
#                 float(item.get('pm25Value', 0))
#             ),
#             'recorded_at': datetime.datetime.now()
#         }
    
    
#     def _get_location_name(self, location_code):
#             """위치 코드를 이름으로 변환"""
#             # 확장된 위치 매핑
#             location_mapping = {
#                 # 수도권
#                 '60,127': '서울',
#                 '55,124': '인천',
#                 '61,125': '경기북부',
#                 '62,120': '경기북부',
#                 '62,126': '경기남부',
#                 '61,131': '경기남부',
#                 '65,130': '경기남부',
                
   
#                 '73,134': '원주',
#                 '84,135': '강원영동',
#                 '92,131': '강원영동',
#                 '73,127': '강원영서',
                
#                 '63,89': '대전',
#                 '68,87': '세종' ,
#                 '68,107': '충남',
#                 '69,106': '충남',
#                 '67,100': '충남',
#                 '68,83': '충북',
#                 '76,88': '충북',
                
#                 '89,90': '대구',
#                 '98,76': '부산',
#                 '91,77': '울산',
#                 '91,106': '경북',
#                 '80,70': '경남',
#                 '87,68': '경남',
#                 '81,75': '경남',
#                 '102,84': '경북',
                
#                 '51,67': '광주',
#                 '59,74': '전북',
#                 '56,71': '전북',
#                 '58,64': '전북',
#                 '56,53': '전남',
#                 '63,56': '전남',
                
#                 '52,38': '제주'
#             }
#             return location_mapping.get(location_code, '알 수 없는 위치')
#     def _calculate_aqi(self, pm10, pm25):
#         """미세먼지 수치를 공기질 지수로 변환"""
#         # 간단한 예시 로직
#         if pm10 <= 30 and pm25 <= 15:
#             return '좋음'
#         elif pm10 <= 80 and pm25 <= 35:
#             return '보통'
#         elif pm10 <= 150 and pm25 <= 75:
#             return '나쁨'
#         else:
#             return '매우 나쁨'
    
#     async def save_dust_data(self, db: Session, dust_data):
#         """미세먼지 데이터를 데이터베이스에 저장"""
#         if not dust_data:
#             return None
            
#         db_air_quality = AirQuality(
#             location_code=dust_data['location_code'],
#             location_name=dust_data['location_name'],
#             pm10=dust_data['pm10'],
#             pm25=dust_data['pm25'],
#             air_quality_index=dust_data['air_quality_index'],
#             recorded_at=dust_data['recorded_at']
#         )
        
#         db.add(db_air_quality)
#         db.commit()
#         db.refresh(db_air_quality)
#         return db_air_quality
import requests
import datetime
import xml.etree.ElementTree as ET
from sqlalchemy.orm import Session
from ..models import AirQuality
from ..config import settings
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

BUSAN_STATIONS = ["연제구", "중구", "사상구", "해운대구", "부산진구", "남구", "동구", "사하구"]

class DustService:
    def __init__(self):
        self.api_key = settings.DUST_API_KEY
        # 날씨 서비스 키는 별도로 관리
        self.weather_api_key = settings.WEATHER_API_KEY if hasattr(settings, 'WEATHER_API_KEY') else self.api_key
    
    def is_station_valid_and_available(self, station_name: str) -> bool:
        """측정소명이 유효하고 현재 실시간 데이터 수집이 가능한지 확인"""
        url = (
            "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"
        )

        params = {
            'serviceKey': self.api_key,
            'returnType': 'json',
            'numOfRows': '1',
            'pageNo': '1',
            'stationName': station_name,
            'dataTerm': 'DAILY',
            'ver': '1.0'
        }

        try:
            # 요청 시도 전 로깅
            logger.info(f"Checking station availability for: {station_name}")
            
            # 요청 타임아웃 및 재시도 설정 추가
            response = requests.get(url, params=params, timeout=10)
            
            # 응답 확인 로깅
            logger.info(f"Response status: {response.status_code}")
            
            # 응답 형식 확인 - XML인지 JSON인지
            content_type = response.headers.get('Content-Type', '')
            is_xml = ('xml' in content_type.lower() or response.text.strip().startswith('<'))
            
            if is_xml:
                # XML 응답 처리
                try:
                    root = ET.fromstring(response.text)
                    # 에러 메시지 확인
                    error_msg = root.find('.//errMsg')
                    return_auth_msg = root.find('.//returnAuthMsg')
                    
                    if error_msg is not None and return_auth_msg is not None:
                        if 'SERVICE_KEY_IS_NOT_REGISTERED_ERROR' in return_auth_msg.text:
                            logger.error(f"API key error: {return_auth_msg.text}")
                            logger.error("API key is not registered for this service. Please check your API key configuration.")
                            return False
                    
                    logger.warning(f"XML response (probably an error): {response.text[:200]}")
                    return False
                except ET.ParseError as e:
                    logger.error(f"XML parse error: {e}")
                    logger.error(f"Response content: {response.text[:200]}")
                    return False
            else:
                # JSON 응답 처리
                try:
                    data = response.json()
                    result_code = data.get("response", {}).get("header", {}).get("resultCode", "")
                    items = data.get("response", {}).get("body", {}).get("items", [])

                    if result_code == "00" and items:
                        logger.info(f"✅ Station {station_name} is available")
                        return True
                    else:
                        logger.warning(f"⚠️ API response failed or no data. Station: {station_name}")
                        if result_code != "00":
                            logger.warning(f"Result code: {result_code}")
                        return False
                except ValueError as e:
                    logger.error(f"JSON parse error: {e}")
                    logger.error(f"Response content: {response.text[:200]}")
                    return False
                
        except requests.exceptions.RequestException as e:
            logger.error(f"⚠️ Request exception: {e}")
            return False
        except Exception as e:
            logger.error(f"⚠️ Unexpected exception: {e}")
            return False

    def get_available_station_in_busan(self) -> str:
        """부산에서 사용 가능한 측정소를 순차적으로 확인하고 하나 리턴"""
        logger.info("Searching for available station in Busan")
        for station in BUSAN_STATIONS:
            # 연속 API 호출 방지를 위한 딜레이
            time.sleep(1)
            if self.is_station_valid_and_available(station):
                logger.info(f"✅ Using alternative station: {station}")
                return station
        logger.error("❌ No available stations in Busan region")
        return None
        
    async def fetch_dust_data(self, location_code):
        """공공데이터 포털 미세먼지 API 호출"""
        station_name = self._get_station_name(location_code)
        logger.info(f"Fetching dust data for location code {location_code}, station: {station_name}")
        
        url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty"

        # 등록된 API 키가 있는지 우선 확인
        if not self._check_api_key_registration():
            logger.error("API key is not registered for this service. Using fallback data.")
            return self._get_fallback_dust_data(location_code)

        # 유효한 측정소 확인 및 대체
        if not self.is_station_valid_and_available(station_name):
            logger.warning(f"⚠️ No data from primary station '{station_name}', trying alternatives")
            if location_code == "98,76":  # 부산인 경우
                station_name = self.get_available_station_in_busan()
                if not station_name:
                    logger.error("Failed to find alternative station")
                    return self._get_fallback_dust_data(location_code)
            else:
                logger.error(f"No alternative station configured for location_code: {location_code}")
                return self._get_fallback_dust_data(location_code)

        params = {
            'serviceKey': self.api_key,
            'returnType': 'json',
            'numOfRows': '1',
            'pageNo': '1',
            'stationName': station_name,
            'dataTerm': 'DAILY',
            'ver': '1.0'
        }

        try:
            # 요청 타임아웃 설정
            response = requests.get(url, params=params, timeout=10)
            
            # 디버깅을 위한 정보
            logger.info(f"▶ Actual request URL: {response.url}")
            logger.info(f"▶ Response status code: {response.status_code}")
            
            # 응답 로깅 (보안상 민감한 정보가 없는 일부만)
            safe_url = response.url.split("serviceKey=")[0] + "serviceKey=HIDDEN" + response.url.split("serviceKey=")[1].split("&")[1:]
            logger.info(f"▶ Sanitized URL: {safe_url}")
            
            # 응답 형식 확인 - XML인지 JSON인지
            content_type = response.headers.get('Content-Type', '')
            is_xml = ('xml' in content_type.lower() or response.text.strip().startswith('<'))
            
            if is_xml:
                # XML 응답 처리 - 주로 오류 메시지임
                logger.error("Received XML response (likely an error)")
                return self._get_fallback_dust_data(location_code)
            
            # 응답이 유효한 JSON인지 확인
            try:
                data = response.json()
            except ValueError as ve:
                logger.error(f"❌ JSON parsing failed: {ve}")
                logger.error(f"Response text: {response.text[:200]}...")
                return self._get_fallback_dust_data(location_code)

            # 결과 코드 확인
            if data.get('response', {}).get('header', {}).get('resultCode') == '00':
                items = data.get('response', {}).get('body', {}).get('items', [])
                if items:
                    logger.info("Successfully retrieved dust data")
                    return self._parse_dust_data(items[0], location_code, station_name)
                else:
                    logger.error("❌ No items in response")
            else:
                result_code = data.get('response', {}).get('header', {}).get('resultCode')
                result_msg = data.get('response', {}).get('header', {}).get('resultMsg')
                logger.error(f"❌ API failed response: code={result_code}, message={result_msg}")
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Request error: {e}")
        except Exception as e:
            logger.error(f"Unexpected error fetching dust data: {e}")
            
        return self._get_fallback_dust_data(location_code)
        
    def _check_api_key_registration(self):
        """API 키가 서비스에 등록되어 있는지 확인"""
        # 가장 단순한 요청으로 API 키 유효성 테스트
        test_url = "http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRltmMesureDnsty"
        params = {
            'serviceKey': self.api_key,
            'returnType': 'json',
            'numOfRows': '1',
            'pageNo': '1',
            'sidoName': '서울',
            'ver': '1.0'
        }
        
        try:
            response = requests.get(test_url, params=params, timeout=5)
            
            # XML 응답인지 확인 (오류일 가능성)
            if response.text.strip().startswith('<'):
                try:
                    root = ET.fromstring(response.text)
                    return_auth_msg = root.find('.//returnAuthMsg')
                    
                    if return_auth_msg is not None and 'SERVICE_KEY_IS_NOT_REGISTERED_ERROR' in return_auth_msg.text:
                        logger.error("API key is not registered for this service")
                        return False
                except:
                    pass
                    
            # JSON 응답 확인
            try:
                data = response.json()
                result_code = data.get("response", {}).get("header", {}).get("resultCode", "")
                if result_code == "00":
                    return True
            except:
                pass
                
            return False
        except:
            return False
            
    def _get_fallback_dust_data(self, location_code):
        """API 호출 실패 시 기본 데이터 제공"""
        # 일반적인 값으로 기본 데이터 생성
        logger.info(f"Using fallback dust data for {location_code}")
        return {
            'location_code': location_code,
            'location_name': self._get_location_name(location_code),
            'station_name': self._get_station_name(location_code),
            'pm10': 35.0,  # 보통 수준의 기본값
            'pm25': 15.0,  # 보통 수준의 기본값
            'air_quality_index': '보통',
            'is_fallback': True,  # 이 데이터가 기본값임을 표시
            'recorded_at': datetime.datetime.now()
        }
    
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
            '98,76': '중구',        # 부산
            '91,77': '울산',        # 울산
            '81,75': '창원',        # 경남
            '102,84': '경주시',     # 경북
            '51,67': '광주',        # 광주
            '59,74': '전주시',      # 전북
            '56,53': '목포시',      # 전남
            '52,38': '제주시',      # 제주
        }
        return station_mapping.get(location_code, '종로구')  

    def _parse_dust_data(self, item, location_code, station_name=None):
        """API 응답 데이터 파싱"""
        # 누락된 데이터 처리
        try:
            pm10 = float(item.get('pm10Value', 0)) if item.get('pm10Value') not in [None, '-'] else 0
            pm25 = float(item.get('pm25Value', 0)) if item.get('pm25Value') not in [None, '-'] else 0
            
            result = {
                'location_code': location_code,
                'location_name': self._get_location_name(location_code),
                'station_name': station_name or self._get_station_name(location_code),
                'pm10': pm10,
                'pm25': pm25,
                'air_quality_index': self._calculate_aqi(pm10, pm25),
                'recorded_at': datetime.datetime.now()
            }
            logger.info(f"Parsed dust data: PM10={pm10}, PM25={pm25}")
            return result
        except Exception as e:
            logger.error(f"Error parsing dust data: {e}")
            logger.error(f"Item content: {item}")
            return None
    
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