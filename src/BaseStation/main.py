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
import socket
from Login import Login

def main():
    Password = Login()

    size = 1024
    s = socket.socket()
    host = socket.gethostname()
    port = 8128
    s.bind((host,port))

    s.listen(5)

    while True:
        client, address = s.accept()
        print("Connected!")
        data = client.recv(size)
        if data:
            print(data)
            if data == bytes("quit\n", 'UTF-8'):
                break
        client.close()

if __name__ == '__main__':
    main()