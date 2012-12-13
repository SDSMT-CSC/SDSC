import socket
import json
import sys

HOST = 'joshsmac.local'
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

text = '''
        {
          "HRHomeStationsRequest":[
            {"StationDID":"hello"},
            {"StationDID":"stuff"}
          ]
        }
      '''

# text = '''
#         {
#           "HRHomeStationUpdate": {"StationDID":"basestation", "StationIP":"0.0.0.5"}
#         }
#        '''

s.sendall(text)

data = s.recv(1024)
s.close()
print 'Received', repr(data)

