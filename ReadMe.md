# Proof of Concept
# Soma Connect REST API / Home Assistant REST API


## Casus

### Background
We have 3 Soma devices: https://www.somasmarthome.com/ 
The three devices are a [Soma Tilt](https://www.somasmarthome.com/pages/smart-tilt) and two [Soma Smart Shades 2](https://www.somasmarthome.com/).


These are connected through a [Soma Connect](https://www.somasmarthome.com/products/soma-connect-blinds-control-for-amazon-alexa-apple-homekit-google-home) which is basically a Raspberry Pi. Another Pi is running [Home Assistant](https://www.home-assistant.io/) as a [Docker](https://www.docker.com/) container. It is linked to the Soma Connect using [Soma Connect Integration](https://www.home-assistant.io/integrations/soma/).

### App(s)
Soma provides an App through the Apple and Google App-Stores called [Smart Shades](https://play.google.com/store/apps/details?id=com.wazombi.RISE). I think it can be improved a great deal, but it seems to do it's primary job: link devices to the Soma Connect and configure them. The most important settings are the minimal and maximal positions of the devices which defines if shades are open or closed.

Home Assustant can be controlled by voice, website or also by an [Home Assistant App](https://play.google.com/store/apps/details?id=io.homeassistant.companion.android).

A huge difference between the two apps to control Soma devices is:
* The Soma App allows for directing the opening/closing to a certain position. The device starts spinning and moves the shades to the requested position.
* The HA App has three buttons. 'Up', 'Down' and 'Stop'. If you hit 'up' or 'down' it keeps going until you hit 'stop'.

### Issue to be researched
On several occasions I noticed the HA app reporting the shades were either in the minimum or maximum position resulting in the associated arrow/button being greyed out. However this was not true in reality. The Soma Shades app did also not report the device to be in the maximum or minimum position.

#### Resulting issues
* One would expect the HA and Soma App to be in sync. So one can to use them at will although resorting to a single one (the HA one) is the goal.
* The shades might not be able to be fully opened or closed using the HA App.
* If the shades are fully opened or closed, but the app things they are not it can still send a 'move command' to adjust the position although this is not desirable.
* I implemented this Home Automation system to aid someone with multiple [Rheumatic disorders](https://en.wikipedia.org/wiki/Rheumatism) so it has to be reliable as the person controlling the system can not always be sure what their hands will do. You want the body to be the only possible culprit, not the system, as that way the automation becomes a problem and not an aid.

#### How to reseach and commence?
* Write some code to read data from Soma Connect/Soma devices uing the [Soma beta REST API](https://support.somasmarthome.com/hc/en-us/articles/360026064234-HTTP-API) and write some code to get data from Home Assistant using the [HA REST API](https://developers.home-assistant.io/docs/api/rest/). In theory the position data should be the same.
* Do some manual further experimentation with the Soma devices.
* Contact Soma and the author or the Soma HA integration.

## Work In Progress

I have contacted Soma support by mail. And reported an [issue through Guthub](https://github.com/home-assistant/core/issues/50782).
Another thing I did was write some Python-code. This code can be found in this repository. It isn't properly linted etc etc. It it just what it is: Proof Of Concept.

### entities.txt
A list of Soma devices as published in HA is put into this file.
It has 4 columns: Name, Entity ID, Integration, Location
The last one is optional. The file is parsed using a Regular Expression. With a big thanks to the folks at the rexex101 IRC Channel for some help on this. It supports division of columns by tab(s) or 2 or more spaces.

#### Why is this needed
The HA REST API does not support listing devices. 
* https://developers.home-assistant.io/docs/api/supervisor/endpoints/
* https://developers.home-assistant.io/docs/api/rest
  
  GET /api/states  

provides all states without(!) a tag of the used integration, only entity_id which can be anything.
So there is no way to know if a state is a state of a Soma Connect device.

### ent.sh
Just a short Python script to test read the entries.txt file and print its contents.

### soma.sh
Python script which calls the, configurable, Soma Connect server URL and port directly. So without the existing [Soma Connect wrapper](https://pypi.org/project/pysoma/). It queries all devices.
The API has some drawbacks / not (yet?) implemented features which would be useful for our purpose:
* firmware version shows the firmware version of the Soma Connect, not the device
* 'last_changed' and 'last_updated' (or similar) are things that can be retrieved using the HA REST API, but not using the Soma API so they cannot be compared.

### soma-ha.sh
This Python script needs 2 files. **bearer.txt** which hold the authorization bearer which you must generate in your profile as documented [here](https://developers.home-assistant.io/docs/api/rest/).
The other is the **entries.txt** file which is documented above.

You guessed it: the script reads all it can from the Soma devices using the HA REST API and prints it to screen.


## Results

We now can run both **soma.sh** and **soma-ha.sh** to see if the values match, And they do not. But it will take a series of runs and physical adjustments (moving of shades) to actually come to reliable conclusions.

## Further testing
When on site I can test and see the physical position and compare it to values retrieved using both the HA REST API and the Soma REST API. In theory they should all match.
In the meantime I created a flowchart using Mermaid. It can be found in a separate MarkDown file. Mermaid is sadly still not supported by Github.
