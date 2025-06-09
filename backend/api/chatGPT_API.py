import os, sys
from urllib import request
from bs4 import BeautifulSoup
import asyncio
from chatGPT import callChatGPT  # 직접 만든 ChatGPT 호출 모듈

try:
    import speech_recognition as sr
    import pvporcupine
    from pvrecorder import PvRecorder
    from gtts import gTTS
    from playsound import playsound
    import feedparser
except ImportError:
    os.system('pip install --upgrade pip')
    os.system('pip install SpeechRecognition')
    os.system('pip install pvporcupine')
    os.system('pip install pvrecorder')
    os.system('pip install gtts')
    os.system('pip install feedparser')
    os.system('pip install playsound==1.2.2')
    sys.exit()

print("[대기] 잠시만 기다려주세요..")

async def my_tts(text):
    print('[AI] : ' + text)
    tts = gTTS(text=text, lang='ko')
    file_name = 'voice.mp3'
    file_path = os.path.abspath(file_name)

    tts.save(file_path)

    loop = asyncio.get_event_loop()
    await loop.run_in_executor(None, playsound, file_path)

    if os.path.exists(file_path):
        os.remove(file_path)

# 기존 STT 함수: 마이크 입력 → 비활성화 (주석처리)
# async def STT():
#     r = sr.Recognizer()
#     with sr.Microphone(1) as source:
#         audio = r.listen(source)
#         try:
#             text = r.recognize_google(audio, language='ko-KR')
#             print('You said: {}'.format(text))
#             await ai(text)
#         except Exception as err:
#             print(err)
#             await my_tts("잘 못 들었어요. 다시 말해주세요.")
#             await STT()

# 텍스트 입력 테스트용 함수
async def text_input_test():
    print("[TEST MODE] 텍스트 입력 모드입니다. 종료하려면 '종료'를 입력하세요.")
    while True:
        text = input("당신 > ")
        if text.strip() == "종료":
            await my_tts("다음에 또 만나요")
            break
        await sumi(text)

### 키워드 감지 (비활성화)
# porcupine = pvporcupine.create(
#     access_key='---',
#     keyword_paths=[os.getcwd()+"\\안녕_ko_windows_v3_0_0.ppn"],
#     model_path=os.getcwd()+"\\porcupine_params_ko.pv",
# )

# async def detect_keyword():
#     recorder = PvRecorder(frame_length=512, device_index=1)
#     recorder.start()
#     while True:
#         pcm = recorder.read()
#         keyword_index = porcupine.process(pcm)
#         if keyword_index == 0:
#             recorder.delete()
#             await my_tts("무엇을 도와드릴까요?")
#             await STT()
#             recorder = PvRecorder(frame_length=512, device_index=1)
#             recorder.start()

# 메인 실행 함수 (비활성화)
# async def main():
#     file_name = 'turn_on.mp3'
#     file_path = os.path.abspath(file_name)
#     loop = asyncio.get_event_loop()
#     await loop.run_in_executor(None, playsound, file_path)
#     print("[실행 가능] 마이크가 준비되었습니다")
#     await detect_keyword()


### ChatGPT 연동 창문 명령 처리
async def sumi(speech):
    response = callChatGPT(speech)
    print(f"[GPT 응답 원문]: {response}")

    import json
    try:
        parsed = json.loads(response)
        action = parsed.get("action")
        message = parsed.get("message", "")
        await my_tts(message)

        if action == "open":
            print("[ACTION] 창문 열기 실행")
        elif action == "close":
            print("[ACTION] 창문 닫기 실행")
        elif action == "greet":
            print("[ACTION] 인사 응답")
        elif action == "none":
            print("[ACTION] 무응답 처리")
    except json.JSONDecodeError:
        print("[ERROR] 응답 파싱 실패, 응답 내용:", response)
        await my_tts("죄송해요. 말씀을 이해하지 못했어요.")

# 실행 entry point
if __name__ == '__main__':
    asyncio.run(text_input_test())