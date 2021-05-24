#!/usr/bin/env python3

import re

HA_ENTITIES_FILE="entities.txt"

regex = r"^(.+?)(?:\t+| {2,})(.+?)(?:\t+| {2,})(.+?)(?:\t+| {2,}|$)(?:(.+?)(?=\t+| {2,}|$))?"

try:
    f=open(HA_ENTITIES_FILE, "r")
    l=f.readlines()
    f.close()
except OSError:
    print("Could not open/read file:", HA_ENTITIES_FILE)
    sys.exit()

#entities ={"Name":[], "EntityID":[], "Integration":[], "Area":[]}
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

            #entities["Name"].append(e_name)
            #entities["EntityID"].append(e_entityID)
            #entities["Integration"].append(e_integration)
            #entities["Area"].append(e_area)

            entities.append({'Name': e_name, 'EntityID': e_entityID, 'Integration': e_integration, 'Area': e_area})

#print(entities)

for entity in entities:
    print("Entity:")
    print("  Name : ", entity['Name'])
    print("  EntityID : ", entity['EntityID'])
    print("  Integration : ", entity['Integration'])
    print("  Area : ", entity['Area'])


