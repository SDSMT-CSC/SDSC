import socket
import json

HOST = 'joshsmac.local'
PORT = 8128
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST, PORT))

s.send('')

raw = s.recv(1024)

data = json.loads(raw)

print data

text = '''
        {
          "HRHomeStationsRequest":[
            {"StationDID":"hello"},
            {"StationDID":"goaway"}
          ]
        }
      '''

# text = '''
#         {
#           "HRHomeStationUpdate": {"StationDID":"goaway", "StationIP":"0.0.0.3"}
#         }
#        '''

s.sendall(text)
data = s.recv(1024)
s.close()
print 'Received', repr(data)

while 1:
  do = raw_input()
