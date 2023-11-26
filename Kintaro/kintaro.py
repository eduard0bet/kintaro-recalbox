#!/usr/bin/python -u                                                                                                                                      
#                                      ▄▄= _╓_
#                                    ╓██▄▓██████▄_
#                                   j██████████████▄
#                                   ╫████████████▀"
#                                   ╫█████████╙
#                                 ,▄▓███████▓,
#                               ▄██████████████▄
#                              ª▀▀▀▀▀▀▀▀▀▀▀▀████H
#                         _,▄▄▓▓██████████▓▓████Ñ
#                     ,▄██████████████████████████▓▄_
#                  _▄█████████████████████████████████▄_
#                 ▄██████████████████████████████████████╓
#               ╓█████████████^╟██████████████████████████▓_
#              ╔█████████████  ▓████████████████████████████▄
#             ╔█████▀▀▀╙╙""`   ````""╙╙▀▀▀████████████╕'█████▄
#            ╓███,▄▄H                        └╙▀███████_▐█████╕
#            ██████▌  ▄▓▀▀▄╓          _╓▄▄▄▄╖_    ╙╙███▌ ██████_
#           ╫█████▌  ²╙  _ ╙▀       ▓▀╙"    '█H      _╙Ñ ▓█████▓
#          ▐██████      ▓██_ ,,        ▄█▌_  ``      ╟█▄|███████▒
#          ██████Ñ      `╙^_█╙╙▀▓▄    '███`          ╚███████████╕
#         ╟██████          `"    `                   [████████████
#        ╓██████▌     ▄▄▓█▓▀▀▀▀▀▀▓φ▄▄,_              [█████████████
#        ▓██████▌      ╟███▄╓,_____,,╠███▓▄▄▄        j██████████████
#       ║███████▌      '█████████████████▓           ▐███████████████╖
#      ╓█████████_      `████╙"]█▀╙"'╙██╜            ║█████████████████▄
#      ███████████_       ╙▓▄╓,╙`_,▄▓▀^              ╫█████████████```
#     ▓████████████_         '╙╙╙╙"                 _██████████████▌
#   _▓██████████████▄_     ª█      ,▄@            _▄████████████████H
#  »▓█████▀▀▀▀▀███████▌,    ╙▀▓▓▓▀▀╙`          _▄▓▀`╫████████▀╙▀▀▀▀██_
#              ╚█████▀╙╙▀▓▄,__           _,,▄▓▀▀"  ,██████▀"
#               ╙▀"        "╙▀▀▀▀▀▀▀▀▀▀▀▀▀╙"       ╙▀╙"                                                                                                                                                                                                                   
# Copyright 2016 Kintaro Co.                                                                                                                                                     
# Copyright 2018 Michael Kirsch 
# Copyright 2023 Eduardo Betancourt

import time
import os
import RPi.GPIO as GPIO
import logging


class SNES:

    def __init__(self):
        # GPIO pins
        self.led_pin = 7
        self.fan_pin = 8
        self.reset_pin = 3
        self.power_pin = 5
        self.check_pin = 10

        # Variables
        self.fan_hysteresis = 20
        self.fan_starttemp = 60
        self.debounce_time = 0.1

        # Path for temperature reading
        self.temp_command = 'cat /sys/class/thermal/thermal_zone0/temp'

        # Set up logging
        logging.basicConfig(
            level=logging.DEBUG,
            filename='/tmp/kintaro.log',
            format='%(asctime)s - %(levelname)s - %(message)s'
        )

        # Set up GPIO pins
        GPIO.setmode(GPIO.BOARD)
        GPIO.setwarnings(False)
        GPIO.setup(self.led_pin, GPIO.OUT)
        GPIO.setup(self.fan_pin, GPIO.OUT)
        GPIO.setup(self.power_pin, GPIO.IN)
        GPIO.setup(self.reset_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.setup(self.check_pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        self.pwm = GPIO.PWM(self.fan_pin, 50)
        self.pwm.start(0)

    def power_interrupt(self, channel):
        logging.debug('Power button interrupt triggered.')
        time.sleep(self.debounce_time)
        if GPIO.input(self.power_pin) == GPIO.HIGH and GPIO.input(self.check_pin) == GPIO.LOW:
            self.led(0)
            logging.info('Shutting down the system.')
            os.system("shutdown -h now")
        logging.getLogger().handlers[0].flush()

    def reset_interrupt(self, channel):
        logging.debug('Reset button interrupt triggered.')
        if GPIO.input(self.reset_pin) == GPIO.LOW:
            time.sleep(self.debounce_time)
            self.blink(3, 0.1)
            logging.info('Rebooting the system.')
            os.system("shutdown -r now")
        logging.getLogger().handlers[0].flush()

    def pcb_interrupt(self, channel):
        GPIO.cleanup()  # Clean up GPIO pins when PCB is pulled

    def temp(self):  # Read GPU temperature
        res = os.popen(self.temp_command).readline()
        return float((res.replace("temp=", "").replace("'C\n", "")))

    def pwm_fancontrol(self, hysteresis, starttemp, temp):
        perc = 100.0 * ((temp - (starttemp - hysteresis)) /
                        (starttemp - (starttemp - hysteresis)))
        perc = min(max(perc, 0.0), 100.0)
        self.pwm.ChangeDutyCycle(float(perc))

    def led(self, status):  # Toggle the LED on or off
        if status == 0:  # The LED is inverted
            GPIO.output(self.led_pin, GPIO.LOW)
        if status == 1:
            GPIO.output(self.led_pin, GPIO.HIGH)

    def blink(self, amount, interval):  # Blink the LED
        for x in range(amount):
            self.led(1)
            time.sleep(interval)
            self.led(0)
            time.sleep(interval)

    def check_fan(self):
        # Fan starts at 60 degrees and has a 5 degree hysteresis
        self.pwm_fancontrol(self.fan_hysteresis,
                            self.fan_starttemp, self.temp())

    def attach_interrupts(self):
        # Check if there is a PCB and if so, attach the interrupts
        if GPIO.input(self.check_pin) == GPIO.LOW:
            # If not, the interrupt gets attached
            GPIO.add_event_detect(
                self.check_pin, GPIO.RISING, callback=self.pcb_interrupt)
            # When the system starts in the ON position, it gets shut down
            if GPIO.input(self.power_pin) == GPIO.HIGH:
                os.system("shutdown -h now")
            else:
                self.led(1)
                GPIO.add_event_detect(
                    self.reset_pin, GPIO.FALLING, callback=self.reset_interrupt)
                GPIO.add_event_detect(
                    self.power_pin, GPIO.RISING, callback=self.power_interrupt)
        else:  # No PCB attached, so let's exit
            GPIO.cleanup()
            exit()


# Create an instance of the SNES class
snes = SNES()
# Attach the interrupts
snes.attach_interrupts()

# Turn on the LED at the beginning
snes.led(1)

while True:
    time.sleep(5)  # Wait for 5 seconds
    snes.check_fan()  # Control the fan
