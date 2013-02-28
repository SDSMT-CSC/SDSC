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
import socket,sys

def main():
    s = socket.socket()         # Create a socket object
    host = socket.gethostname() # Get local machine name
    port = 8128                 # Reserve a port for your service.

    s.connect((host, port))
    while True:
        message = sys.stdin.readline()
        s.sendall(message.encode('UTF-8'))
                
        if (message == "quit\n"):
            break

    s.close()                     # Close the socket when done

if __name__ == '__main__':
    main()
