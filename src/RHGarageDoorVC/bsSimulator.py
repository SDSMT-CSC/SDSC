import socket
import time
import sys

soc = socket.socket()

soc.bind((socket.gethostname(),8128))

print "Base Station Simulator ready"

while 1:
  soc.listen(5)

  conn, addr = soc.accept()

  time.sleep(1)

  conn.send('''{"DDNSConnected":[{"Connected":true}]}''')

  request = conn.recv(4096)

  print request

  response = raw_input("Enter a response: ")

  conn.send(response)

  print ###############################################################################
