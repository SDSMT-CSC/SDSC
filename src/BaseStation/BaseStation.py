#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      1886327
#
# Created:     26/02/2013
# Copyright:   (c) 1886327 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python           # This is client.py file
import socket#, serial
from Login import Login

def main():
    #Password = Login()
    Socket_Communicate(Listen())



def Listen():
    s = socket.socket()
    host = socket.gethostname()
    port = 8128
    s.bind((host,port))

    s.listen(5)
    return s

def Socket_Communicate(s):
    size = 1024

    while True:
        client, address = s.accept()
        print("Connected!")
        while True:
            data = client.recv(size).strip()
            if data:
                if data == "quit".encode('UTF-8'):
                    break
                print(data)
                #Serial_Communicate(data)
        if data == "quit".encode('UTF-8'):
            break

    client.close()

#def Serial_Communicate(message):
#    s = serial.Serial('/dev/ttyUSB0', 9600)
#
#    s.write(message)
#    time.sleep(10)
#    s.flushOutput()

if __name__ == '__main__':
    main()
