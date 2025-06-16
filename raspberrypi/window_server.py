from fastapi import FastAPI, Request
import RPi.GPIO as GPIO
import time

app = FastAPI()

SERVO_PIN = 23

# GPIO 초기 설정
GPIO.setmode(GPIO.BCM)
GPIO.setup(SERVO_PIN, GPIO.OUT)
servo = GPIO.PWM(SERVO_PIN, 50)  # 50Hz = 20ms 주기
servo.start(0)

# 마이크로초(us) 단위로 서보모터 각도 제어
def set_angle_us(us):
    duty = us / 20000 * 100
    servo.ChangeDutyCycle(duty)
    time.sleep(1)

# 명령 수신 API
@app.post("/receive-cmd")
async def receive_command(req: Request):
    data = await req.json()
    action = data.get("action", "").upper()

    if action == "OPEN":
        print("Receive window open command")
        set_angle_us(2300)  # 넓게 열기
    elif action == "CLOSE":
        print("Receive window close command")
        set_angle_us(500)  # 좁게 닫기
    else:
        print("Unknown command:", action)

    return {"status": "received", "action": action}

# 종료 시 GPIO 정리
import atexit
@atexit.register
def cleanup():
    servo.stop()
    GPIO.cleanup()
