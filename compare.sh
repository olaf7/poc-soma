#!/usr/bin/env python3
# (c) Olaf Zevenboom 2021
# version : 0.1
# MIT License
# use at own risk

import requests
import sys
import json
import time

HA_BEARER_FILE = "bearer.txt"
SOMA_DEV_FILE = "mac.txt"

#DEVICE_MAC="" # MAC address of device as used by Soma Connect API
#DEVICE_HA_NAME="cover.somatilt1" # Home Assistant Identity ID of device

WAIT=5 # wait time in seconds between calls
ACTIVITY_WAIT=20 # time it takes to perform action (ie close blinds)

SERVER_HOMEASSISTANT="192.168.178.241"
SERVER_HOMEASSISTANT_PORT=8123
SERVER_HOMEASSISTANT_BEARER_FILE="bearer.txt"

SERVER_HOMECONNECT="192.168.178.22"
SERVER_HOMECONNECT_PORT=3000

POSITION=60 # position % of open state of device

print("Welcome to the Soma Connect positional comparison analyzer POC")

try:
    f=open(SOMA_DEV_FILE, "r")
    l=f.readlines()
    DEVICE_MAC, DEVICE_HA_NAME = l[0].rstrip().split()
    #print("DEBUG: DEVICE_MAC: %s" % DEVICE_MAC)
    #print("DEBUG: DEVICE_HA_NAME : %s" % DEVICE_HA_NAME)
except OSError:
    print("Could not open/read configuration file:", SOMA_DEV_FILE)
    exit(1)

try:
    f=open(HA_BEARER_FILE, "r")
    l=f.readlines()
    HA_BEARER=l[0].rstrip()
    f.close()
except OSError:
    print("Could not open/read configuration file:", HA_BEARER_FILE)
    exit(1)

headers = {
    "Authorization": "Bearer " + HA_BEARER,
    "content-type": "application/json",
}

somaconnect_url = "http://" + SERVER_HOMECONNECT + ":" + str(SERVER_HOMECONNECT_PORT)
somaconnect_timeout = 5  # optional timeout in seconds

homeassistant_url = "http://" + SERVER_HOMEASSISTANT + ":" + str(SERVER_HOMEASSISTANT_PORT)
homeassistant_timeout = 5 # optional timout in seconds

print("  Soma Connect URI : %s" % somaconnect_url)
print("  Home Assistant URI : %s" % homeassistant_url)
print("  Soma Device MAC address : %s" % DEVICE_MAC)
print("  Soma Device identity ID in Home Assistant : %s" % DEVICE_HA_NAME) 

# TEST CONNECTION to : Soma Connect
response = requests.get(url=somaconnect_url + "/list_devices" , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot continue due to error on connecting to Soma Connect : " + str(response.status_code))
    print("URI : %s" % somaconnect_url)
    exit(1)

# TEST CONNECTION to : Home Assistant
response = requests.get(url=homeassistant_url + "/api/" , timeout=homeassistant_timeout, headers=headers)
if response.status_code != 200:
    print("Cannot continue due to error on connecting to Home Assistant : " + str(response.status_code))
    print("URI : %s" % homeassistant_url)
    exit(1)

# READ POSITION of device (Soma Connect)
response = requests.get(url=somaconnect_url + "/get_shade_state/" + str(DEVICE_MAC) , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot connect to Soma device : " + str(DEVICE_MAC) + " : " + str(response.status_code))
data = json.loads(response.text)
device_result1 = data['result']
device_version1 = data['version']
device_mac1 = data['mac']
device_position1 = data['position']

# READ POSITION of device (Home Assistant)
response = requests.get(url=homeassistant_url + "/api/states/" + str(DEVICE_HA_NAME) , timeout=homeassistant_timeout, headers=headers)
if response.status_code != 200:
    print("Cannot fetch HA entity properties of : " + str(DEVICE_HA_NAME) + " : " + str(response.status_code))
data = json.loads(response.text)
hadev_entityid1 = data['entity_id']
hadev_attributes1 = data['attributes']
hadev_last_changed1 = data['last_changed']
hadev_last_updated1 = data['last_updated']
hadev_position1 = data['attributes'].get('current_position')

# SET POSITION of device (Soma Connect)
# https://support.somasmarthome.com/hc/en-us/articles/360026064234-HTTP-API
response = requests.get(url=somaconnect_url + "/set_shade_position/" + str(DEVICE_MAC) + "/" + str(POSITION) , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot connect to Soma device (to set position) : " + str(DEVICE_MAC) + " : " + str(response.status_code))

# WAIT (to finish)
time.sleep(ACTIVITY_WAIT)
time.sleep(WAIT)

# READ POSITION of device (Soma Connect)
response = requests.get(url=somaconnect_url + "/get_shade_state/" + str(DEVICE_MAC) , timeout=somaconnect_timeout)
if response.status_code != 200:
    print("Cannot connect to Soma device : " + str(DEVICE_MAC) + " : " + str(response.status_code))
data = json.loads(response.text)
device_result2 = data['result']
device_version2 = data['version']
device_mac2 = data['mac']
device_position2 = data['position']

# WAIT (for HA to catch up)
time.sleep(WAIT)

# READ POSITION of device (Home Assistant)
response = requests.get(url=homeassistant_url + "/api/states/" + str(DEVICE_HA_NAME) , timeout=homeassistant_timeout, headers=headers)
if response.status_code != 200:
    print("Cannot fetch HA entity properties of : " + str(DEVICE_HA_NAME) + " : " + str(response.status_code))
data = json.loads(response.text)
hadev_entityid2 = data['entity_id']
hadev_attributes2 = data['attributes']
hadev_last_changed2 = data['last_changed']
hadev_last_updated2 = data['last_updated']
hadev_position2 = data['attributes'].get('current_position')

# Report
print("Soma device test script")
print("Comparing position value of:")
print("  MAC-address : " + str(DEVICE_MAC))
print("  HA identity ID : " + str(DEVICE_HA_NAME))
print("Original position values :")
print("  Soma Connect : " + str(device_position1))
print("  Home Assistent : " + str(hadev_position1))
print("After commanding Some Connect to move to position : " +str(POSTION) + ":")
print("  Soma Connect : " + str(device_position2))
print("  Home Assistant : " + str(hdev_position2))
print()
