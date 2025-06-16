import RPi.GPIO as GPIO
import spidev
import requests
import time
import threading

DEVICE_ID = "sensor01"
SERVER_URL = "https://5912-113-198-180-200.ngrok-free.app/iot/data"

PIR_PIN = 17
LIGHT_DO_PIN = 27   
ADC_CHANNEL_GAS = 1   

 
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIR_PIN, GPIO.IN)
GPIO.setup(LIGHT_DO_PIN, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)

spi = spidev.SpiDev()
spi.open(0, 0)
spi.max_speed_hz = 1000000

 
def read_adc(channel):
    adc = spi.xfer2([1, (8 + channel) << 4, 0])
    value = ((adc[1] & 3) << 8) + adc[2]
    return value

 
def send_data(pir=None, light=None, gas=None):
    data = {
        "device_id": DEVICE_ID
    }
    if pir is not None:
        data["pir"] = pir
    if light is not None:
        data["light"] = light
    if gas is not None:
        data["gas"] = gas

    try:
        res = requests.post(SERVER_URL, json=data)
        print(f"[send complete] status={res.status_code}, data={data}")
    except Exception as e:
        print("send failed:", e)

 
def pir_detected(channel):
    print("Motion Detected!") 
    send_data(pir=1)

GPIO.add_event_detect(PIR_PIN, GPIO.RISING, callback=pir_detected, bouncetime=500)

 
def sensor_loop():
    while True:
        light_value = GPIO.input(LIGHT_DO_PIN)   
        gas_value = read_adc(ADC_CHANNEL_GAS)

        if light_value == 0:
            print("light: dark, ", end="") 
        else:
            print("light: bright, ", end="") 

        print(f"gas: {gas_value}") 

        send_data(light=light_value, gas=gas_value)
        time.sleep(5)

 
try:
    threading.Thread(target=sensor_loop).start()
    while True:
        time.sleep(1)

except KeyboardInterrupt:
    print("\nend(user stop it)") 

finally:
    GPIO.cleanup()
    spi.close()


