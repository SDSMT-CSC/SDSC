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
import socket, serial, time
from Login import Login

def main():
    #Password = Login()
    Socket_Communicate()



def Socket_Communicate():
    size = 1024
    sock = socket.socket()
    host = 'localhost' #socket.gethostname()
    port = 8128
    sock.bind((host,port))

    Ser = serial.Serial("COM4", 9600)
    Ser.setTimeout(1)

    while True:
        sock.listen(5)

        while True:
            client, address = sock.accept()
            ## This block needs removed ##
            print(address)
            print("Connected!")
            ##############################
            while True:
                data = client.recv(size).strip()
                if data:
                    if data == "exit".encode("ascii"):
                        return

                    if data == "quit".encode("ascii"):
                        break

                    Ser.write( data )
                    if data == "2".encode("ascii"):
                        print( "State: ", Ser.readline().strip() )

            if data == "quit".encode("ascii"):
                        break

    Ser.close()
    client.close()


if __name__ == '__main__':
    main()
