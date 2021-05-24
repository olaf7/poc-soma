#!/usr/bin/env python3
"""
    Author: Olaf Zevenboom (c) 2021
    Version: 0.1
    License: MIT
"""

# https://developers.home-assistant.io/docs/api/rest/

from requests import get

import re
import sys
import json

HA_URL="http://192.168.178.241"
HA_PORT=8123
HA_BEARER_FILE="bearer.txt"

HA_ENTITIES_FILE="entities.txt"

regex = r"^(.+?)(?:\t+| {2,})(.+?)(?:\t+| {2,})(.+?)(?:\t+| {2,}|$)(?:(.+?)(?=\t+| {2,}|$))?"


try:
    f=open(HA_BEARER_FILE, "r")
    l=f.readlines()
    HA_BEARER=l[0].rstrip()
    f.close()
except OSError:
    print("Could not open/read file:", HA_BEARER_FILE)
    sys.exit()


try:
    f=open(HA_ENTITIES_FILE, "r")
    l=f.readlines()
    f.close()
except OSError:
    print("Could not open/read file:", HA_ENTITIES_FILE)
    sys.exit()


headers = {
    "Authorization": "Bearer " + HA_BEARER,
    "content-type": "application/json",
}

#print(headers)

entities=[]

for el in l:
    match = re.search(regex, el)
    if match:
        if match.group(1).lower() != "name":
            e_name = match.group(1).strip()
            e_entityID = match.group(2).strip()
            e_integration = match.group(3).strip()
            if len(match.groups())>3:
                e_area = match.group(4).strip()
            else:
                e_area = None

            entities.append({'Name': e_name, 'EntityID': e_entityID, 'Integration': e_integration, 'Area': e_area})

#print(entities)

for entity in entities:
    print("Entity:")
    print("  Name : ", entity['Name'])
    print("  EntityID : ", entity['EntityID'])
    print("  Integration : ", entity['Integration'])
    print("  Area : ", entity['Area'])
    HA_ENDPOINT = "api/states/" + entity['EntityID']
    url = HA_URL + ":" + str(HA_PORT) + "/" + HA_ENDPOINT
    response = get(url, headers=headers)
    if response.status_code != 200:
        print("Cannot continue due to error: " + str(response.status_code))
        sys.exit()

     # further parsing needed?
    data=json.loads(response.text)
    #print(data)
    dev_entityid=data['entity_id']
    dev_state=data['state']
    dev_attributes=data['attributes']
    dev_last_changed = data['last_changed']
    dev_last_updated = data['last_updated']
    dev_position = data['attributes'].get('current_position')
    #if hasattr(data, 'position'):
    #    dev_position=data['attributes']['position']

    print(response.text)
    print("Position :", dev_position)
    print("Last changed :", dev_last_changed)
    print("Last updated :", dev_last_updated)
    print("\n")


