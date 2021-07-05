#!/usr/bin/env python3

# Provided as is, use at own risk
# (c) Olaf Zevenboom 2021
# MIT License
# version : 0.4

import requests
import json
import argparse
import time
import pprint
import configobj

SomaConnect="192.168.178.22"
SomaConnectPort=3000

conf = configobj.ConfigObj("devices.conf")
SomaShades_rail = conf.get("SomaShades_rail")
SomaShades_tilt = conf.get("SomaShades_tilt")
SomaTilt_tilt1  = conf.get("SomaTilt_tilt1")

#print(SomaShades_rail)
#print(SomaShades_tilt)
#print(SomaTilt_tilt1)
#exit(0)

SomaTilt_tilt1_open = 50
SomaTilt_tilt1_close = 100
SomaShades_rail_open = 50
SomaShades_rail_close = 100
SomaShades_tilt_open = 50
SomaShades_tilt_close = 0

# https://support.somasmarthome.com/hc/en-us/articles/360026064234-HTTP-API
# note: may change without notice!
# currently no way to query soma-connect directly (alive, version, network, ...)

somaconnect_url = "http://" + SomaConnect + ":" + str(SomaConnectPort)
somaconnect_timeout = 10  # optional 5 seconds timeout

somaaction_wait = 15 # amount of time in seconds to wait to allow an action/command to finish

# get arguments
parser = argparse.ArgumentParser()
parser.add_argument("devicename", type=str,
                    choices=("rail", "tilt1"), 
                    help="available devices: rail, tilt1")
parser.add_argument("command", type=str, 
                    choices=("open", "close"), 
                    help="available commands: open, close")
args = parser.parse_args()
action=args.command
mysoma=args.devicename

#print("Device to use    : %s" % mysoma)
#print("Requested action : %s" % action)
#exit(0)

# get devices
response = requests.get(url=somaconnect_url + "/list_devices" , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot continue due to error: " + str(response.status_code))
    exit(1)

#print(response.text)
#print(response.status_code)


def get_shade_position(mac):
    position = -1
    state_response = requests.get(url=somaconnect_url + '/get_shade_state/' + mac + '' ,  timeout=somaconnect_timeout)
    if state_response.status_code != 200:
         print("Unable to query the device: " + str(state_response.status_code))
         #continue
         #pprint.pprint(state_response.text)
         shade_state = json.loads(state_response.text)
         pprint.pprint(shade_state)
         position = shade_state['position']
    return (response.status_code == 200), position

def set_shade_position(mac, pos):
    response = requests.get(url=somaconnect_url + "/set_shade_position/" + str(mac) + "/" + str(pos) , timeout=somaconnect_timeout)
    if response.status_code != 200:
       print("FAULURE")
       print("Cannot connect to Soma device (to set position) : " + str(DEVICE_MAC) + " : " + str(response.status_code))
       exit(1)
    return (response.status_code == 200)

def get_tilt_position(mac):
    r,p = get_shade_position(mac)
    return r,p

def set_tilt_position(mac, pos):
    return set_shade_position(mac, pos)


### main ###

if mysoma == "rail":
    print("Get position of \'vblinds rail\' ...")
    rc, pos = get_shade_position(SomaShades_rail)
    if not rc:
        print("Unable to get position of device \'vblinds rail\'")
    else:
        print("Current position of device \'vblinds rail\' : %d" % pos)

    print("Get position of \'vblinds tailt\' ...")
    rc, pos = get_shade_position(SomaShades_tilt)
    if not rc:
        print("Unable to get position of device \'vblinds tilt\'")
    else:
        print("Current position of device \'vblinds tilt\' : %d" % pos)

if mysoma == "tilt":
    print("Get position of \'Soma Tilt1\' ...")
    rc, pos = get_tilt_position(SomaTilt_tilt1)
    if not rc:
        print("Unable to get position of device \'SomaTilt1\'")
    else:
        print("Current position of device \'SomaTilt1\' : %d" % pos)

print("Time to wait before adjusting ...")
time.sleep(somaaction_wait)

if mysoma == "rail" and action == "open":
    print("Setting \'vblinds tilt\' position ...")
    if not set_shade_position(SomaShades_tilt, SomaTilt_tilt1_open):
        print("Unable to set position of device \'vblinds tilt\'")
        exit(1)

    time.sleep(somaaction_wait)

    print("Setting \'vblinds rail\' poisition ...")
    if not set_shade_position(SomaShades_rail, SomaShades_rail_open):
        print("Unable to set position of device \'vblinds rail\'")
        exit(1)

    time.sleep(somaaction_wait)

    print("Get position of \'vblinds rail\' ...")
    r, pos = get_shade_position(SomaShades_rail)
    if not r:
        print("Unable to set position of device \'vblinds rail\'")
        exit(1)
    if pos != SomaShades_rail_open :
        print("Unable to set position to requested value")
        exit(1)

if mysoma == "rail" and action == "close":
    # close:
    #   - shades can not be tilt closed : ensure
    #     - tilt (30 < pos < 70)
    #     - change tilt only when rail not open
    #   - close rail
    #   - close tilt

    print("Setting \'vblinds rail\' position ...")
    if not set_shade_position(SomaShades_tilt, SomaShades_tilt_open):
        print("Unable to set position of device \'vblinds tilt\'")
        exit(1)

    time.sleep(somaaction_wait)

    print("Setting \'vblinds rail\' position ...")
    if not set_shade_position(SomaShades_rail, SomaShades_rail_close):
        print("Unable to set position of device \'vblinds rail\'")
        exit(1)

    time.sleep(somaaction_wait)

    print("Setting \'vblinds tilt\' position ...")
    if not set_shade_position(SomaShades_tilt, SomaShades_tilt_close):
        print("Unable to set position of device \'vblinds tilt\'")
        exit(1)

    time.sleep(somaaction_wait)

    print("Get position of \'vblinds rail\' ...")
    r, pos = get_shade_position(SomaShades_rail)
    if not r:
        print("Unable to set position of device \'vblinds rail\'")
        exit(1)
    if pos != SomaShades_rail_close :
        print("Unable to set position to requested value")
        exit(1)

if mysoma == "tilt1" and action == "open":
    print("Setting \'SomaTilt1\' position ...")
    if not set_tilt_position(SomaTilt_tilt1, SomaTilt_tilt1_open):
        print("Unable to set position of device \'SomaTilt1 tilt\' to open")
        exit(1)

if mysoma == "tilt1" and action == "close":
    print("Setting \'SomaTilt1\' position ...")
    if not set_tilt_position(SomaTilt_tilt1, SomaTilt_tilt1_close):
        print("Unable to set position of device \'SomaTilt1 tilt\' to close")
        exit(1)
