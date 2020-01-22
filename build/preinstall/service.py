#!/usr/bin/env python3

import os
import errno

FIFO = "pipe"

try:
    os.mkfifo(FIFO)
except OSError as oe:
    if oe.errno != errno.EEXIST:
        raise

print("Opening FIFO...")

def readFIFO():
    print("Awaiting next command.")
    with open(FIFO) as fifo:
        while True:
            data = fifo.read()
            if len(data) == 0:
                #print("Writer closed")
                break
            #print('Read: "{0}"'.format(data))
            print(data.split()[1])
            print("Command received: {0}".format(data))

while True:
    readFIFO()
