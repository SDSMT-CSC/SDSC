import socket
import json
from finder import Finder

class Server:
  def __init__(self):
    self.hostName = socket.gethostname()
    self.port = 8128
    self.finder = Finder('deviceServer.db')

  #end __init__

  def run(self):
    createDaemon()
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((self.hostName, self.port))
     
    while 1:
      s.listen(5)

      conn, addr = s.accept()

      self.handleConnection(conn,addr)

    s.close()
  #end run

  def handleConnection(self,conn,addr):
    conn.send('''{"DDNSConnected":[{"Connected":true}]}''')

    raw = conn.recv(1024)

    print raw

    data = json.loads(raw)

    if data.keys()[0] == 'HRHomeStationsRequest':
      #get the id values out of the deserialized json
      ids = data.values()[0]

      ips = list()

      for id in ids:
        ips.append(self.finder.find(id.values()[0]))

      conn.sendall(self.buildRequestResponse(ids,ips))
    elif data.keys()[0] == 'HRHomeStationUpdate':
      
      id = data.values()[0].values()[0]

      ip = data.values()[0].values()[1]

      self.finder.update(id,ip)      

      conn.sendall(id + " " + ip)
    else:
      pass

  def buildRequestResponse(self,ids,ips):
    values = list()

    print ids
    print ips

    i = 0
    while i < len(ids):
      values.append({'stationDID':ids[i].values()[0], 'stationIP':ips[i]})
      i += 1

    return json.dumps({'HRHomStationReply':values})
#end Server
