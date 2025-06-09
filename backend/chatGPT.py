import os, sys

# openai 라이브러리 설치 여부 확인
try:
    from openai import OpenAI
except ImportError:
    os.system("pip install openai")
    sys.exit()

# API 키 불러오기 함수
def load_api_key(file_path="apikey.txt"):
    try:
        with open(file_path, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        print(f"[ERROR] '{file_path}' 파일을 찾을 수 없습니다.")
        sys.exit()

# ChatGPT 호출 함수
def callChatGPT(text):
    print("ChatGPT 호출중...")
    api_key = load_api_key()  # apikey.txt에서 키 불러오기
    client = OpenAI(api_key=api_key)

    completion = client.chat.completions.create(
        model="gpt-4-0613",
        messages=[
            {"role": "system", "content": """너는 SOOM이라는 자동환기시스템 어플리케이션의 도우미 '수미'야. 사용자와 자연스럽게 대화하면서 창문을 열지 닫을지를 결정해줘. 다음 규칙들을 따라 응답해. 
1. 사용자가 '수미야'라고 부르면, 반드시 {"action": "greet", "message": "안녕하세요. 무엇을 도와드릴까요?"}라고 응답해.
2. 사용자가 환기를 원하거나 창문을 열고 싶다고 표현하면, {"action": "open", "message": "네, 창문을 열어드리겠습니다."} 형식으로 JSON 응답을 반환해.
3. 사용자가 환기를 중지하거나 창문을 닫고 싶다고 표현하면, {"action": "close", "message": "네, 창문을 닫아드리겠습니다."} 형식으로 JSON 응답을 반환해.
4. 위 조건에 해당하지 않는 경우, 사용자 의도를 파악할 수 없다고 안내해줘. 이때는 {"action": "none", "message": "죄송해요, 무슨 말씀이신지 잘 모르겠어요. 다시 말씀해주시겠어요?"} 라고 응답해.
형식은 항상 JSON 구조로 정확히 맞춰서 반환해."""},
            {"role": "user", "content": text},
        ],
    )
    return completion.choices[0].message.content