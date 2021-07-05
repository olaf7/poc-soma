#!/usr/bin/env python3
# (c) Olaf Zevenboom 2021
# version 0.1
# MIT License
# use at own risk

import requests
import json

SomaConnect="192.168.178.116"
SomaConnectPort=3000

# https://support.somasmarthome.com/hc/en-us/articles/360026064234-HTTP-API
# note: may change without notice!
# currently no way to query soma-connect directly (alive, version, network, ...)

somaconnect_url = "http://" + SomaConnect + ":" + str(SomaConnectPort)
somaconnect_timeout = 5  # optional 5 seconds timeout

# get devices
response = requests.get(url=somaconnect_url + "/list_devices" , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot continue due to error: " + str(response.status_code))
    exit(1)

print(response.text)
print(response.status_code)
data = response.json()

somaconnect_status = data['result'] # Soma Connect query status
somaconnect_version = data['version']

print("SomaConnect version: " + somaconnect_version)


dev_dict=data #json.load(response.text)

for k in dev_dict:
    if k == "shades":
       for d in dev_dict[k]:
          print("----------")
          devname = d['name']
          devmac =  d['mac']
          print("name: " + devname)
          print("mac:" + devmac)

          state_response = requests.get(url=somaconnect_url + '/get_shade_state/' + devmac + '')
          if state_response.status_code != 200:
              print("Unable to query the device: " + str(state_response.status_code))
              continue
          #print(state_response.text)
          shade_state = json.loads(state_response.text)
          state_result = shade_state['result']
          state_version = shade_state['version']
          state_mac = shade_state['mac']
          state_position = shade_state['position']

          print("Result: %s" % state_result)
          print("Version: %s" % state_version)
          print("MAC: %s" % state_mac)
          print("Position: %s" % state_position)

          battery_response=  requests.get(url=somaconnect_url + '/get_battery_level/' + devmac + '')
          if battery_response.status_code != 200:
              print("Unable to query the device: " + str(battery_response))
              continue
          #print(battery_response.text)
          battery_state = json.loads(battery_response.text)
          battery_result = battery_state['result']
          battery_level = battery_state['battery_level'] # 360-410 is normal
          battery_percentage = battery_state['battery_percentage']

          print("Battery result: %s" % battery_result)
          print("Battery level: %s" % battery_level)
          print("Battery percentage: %s" % battery_percentage)

          # API does not yet support:
          # device firmware version
          # device log
          # device on_battery

       print("\n")

    #print("key:" + k + ", value:" + str(dev_dict[k]))


