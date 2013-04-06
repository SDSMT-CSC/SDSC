import socket
import json
import sys

#HOST = 'ec2-54-244-67-241.us-west-2.compute.amazonaws.com'
HOST = '10.250.1.128'
PORT = 8128
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
  s.connect((HOST, PORT))
except Exception, e:
  print e

raw = s.recv(1024)

if raw != '''{"DDNSConnected":[{"Connected":true}]}''':
  print 'Could not connect'
  sys.exit()

text = '''{"HRHomeStationsRequest" : [{ "StationDID" : "imaginary"}]}'''

s.sendall(text)

data = s.recv(1024)
s.close()
print 'Received', repr(data)

