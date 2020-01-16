#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK

import json
from dotenv import load_dotenv
import os
import sys
import requests
import argparse
from colorama import Fore, Style
from time import sleep
import argcomplete

load_dotenv()

def spinning_cursor():
    while True:
        for cursor in '|/-\\':
            yield cursor

def loadDefaultConfig():
    if (os.getenv("FOG_API_TOKEN") == None) or (os.getenv("FOG_USER_TOKEN") == None):
        print("No FOG API Tokens provided.")
        print("Please make sure you have configured your .env file correctly.")
        exit(1)
        pass
    config = {
    "baseURL": "http://fog.c3.furg.br",
    "fog-api-token": os.getenv("FOG_API_TOKEN"),
    "fog-user-token": os.getenv("FOG_USER_TOKEN"),
    }
    return config

def readConfig():
    try:
        with open("config.json") as jsonData:
            config = json.load(jsonData)
        pass
    except FileNotFoundError as e:
        print("No config.json detected!")
        exit(1)
        raise

def writeConfig(data):
    with open('config.json', 'w') as outfile:
        json.dump(data, outfile)

def getFogHostID(name):
    searchURL=config["baseURL"] + "/fog/host/search/" + name
    r = requests.get(searchURL, headers=headers)
    return (r.json()['hosts'][0]['id'])

def getFogTaskTypeId(name):
    searchURL=config["baseURL"] + "/fog/tasktype"
    r = requests.get(searchURL, headers=headers)
    tasktypes = r.json()['tasktypes']
    for type in tasktypes:
        if (type['name'] == name):
            return type['id']

def isTaskigDone(hostID):
    searchURL = config["baseURL"] + "/fog/task/active"
    r = requests.get(searchURL, headers=headers)
    tasks = r.json()['tasks']
    flag = True
    for task in tasks:
        if (task['host']['id']) == hostID:
            flag = False
    return flag

def taskHost(hostID, data):
    taskURL=config["baseURL"] + "/fog/host/" + hostID + "/task"
    r = requests.post(taskURL, data=data, headers=headers)
    return (r.json())

def captureFogCurrentImage(taskTypeID, hostID):
    taskURL=config["baseURL"] + "/fog/host/" + hostID + "/task"
    data = json.dumps({
        "taskTypeID": taskTypeID,
        "shutdown": '',
        "wol": 'true'
    }).encode('utf8')
    r = requests.post(taskURL, data=data, headers=headers)
    return (r.json())

def getHostMacAddress(hostID):
    searchURL = config["baseURL"] + "/fog/host/" + hostID
    r = requests.get(searchURL, headers=headers)
    macs = r.json()['macs']
    list = []
    for mac in macs:
        list.append(mac)
    return list

def wait_if_needed(args):
    if args.wait:
        for x in range(len(args.hosts)):
            print ("Waiting for machine #" + str(x) + ": " + args.hosts[x] + " ", end='')
            while not isTaskigDone(getFogHostID(args.hosts[x])):
                spinner = spinning_cursor()
                for _ in range(4):
                    sys.stdout.write(next(spinner))
                    sys.stdout.flush()
                    sleep(0.3)
                    sys.stdout.write('\b')
            sys.stdout.flush()
            sys.stdout.write('\b')
            print(Fore.GREEN + " Done!" + Style.RESET_ALL)

def cmd_deploy(args):
    print("Total Machines to Deploy: " + str(len(args.hosts)))

    taskData = json.dumps({
        "taskTypeID": getFogTaskTypeId("Deploy"),
        "shutdown": '',
        "wol": 'true'
    }).encode('utf8')

    for x in range(len(args.hosts)):
        print ("Sending request to machine #" + str(x) + ": " + args.hosts[x], end='')
        taskHost(getFogHostID(args.hosts[x]), taskData)
        print(Fore.GREEN + " Done!" + Style.RESET_ALL)

    wait_if_needed(args)

def cmd_capture(args):
    print("Total Machines to Capture: " + str(len(args.hosts)))

    taskData = json.dumps({
        "taskTypeID": getFogTaskTypeId("Capture"),
        "shutdown": '',
        "wol": 'true'
    }).encode('utf8')

    for x in range(len(args.hosts)):
        print ("Sending request to machine #" + str(x) + ": " + args.hosts[x], end='')
        taskHost(getFogHostID(args.hosts[x]), taskData)
        print(Fore.GREEN + " Done!" + Style.RESET_ALL)

    wait_if_needed(args)

def cmd_getmac(args):
    for mac in (getHostMacAddress(getFogHostID(args.host))):
        print(mac)

def main():

    if not (os.path.exists("config.json")):
        writeConfig(config)
    else:
        readConfig()

    parser = argparse.ArgumentParser(description="FOG Python Client: Rafael Souza <rsouza19796@gmail.com>")

    sp = parser.add_subparsers(help="Main operations.")

    sp_deploy = sp.add_parser('deploy', help='Deploys a image to a host.')
    sp_deploy.set_defaults(func=cmd_deploy)
    sp_deploy.add_argument('hosts', nargs='+', help='Host names in the FOG system.')
    sp_deploy.add_argument('--wait', help="Will wait until the task is done. Useful for scripts.", action='store_true')

    sp_capture = sp.add_parser('capture', help='Captures a image from a host.')
    sp_capture.set_defaults(func=cmd_capture)
    sp_capture.add_argument('hosts', nargs='+', help='Host names in the FOG system.')
    sp_capture.add_argument('--wait', help="Will wait until the task is done. Useful for scripts.", action='store_true')

    sp_getmac = sp.add_parser('get-mac', help="Returns a list of a host's MAC addresses.")
    sp_getmac.set_defaults(func=cmd_getmac)
    sp_getmac.add_argument('host', help='Host names in the FOG system.')

    argcomplete.autocomplete(parser)
    args = parser.parse_args()
    args.func(args)


config = loadDefaultConfig()
headers = {
"fog-api-token": config["fog-api-token"],
"fog-user-token": config["fog-user-token"],
"Content-Type": "application/json"
}

if (__name__ == "__main__"):
    main()
