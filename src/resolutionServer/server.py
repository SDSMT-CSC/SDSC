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

    print 'confirmation sent'

    raw = conn.recv(4096)

    print raw


    data = None

    try:
      data = json.loads(raw)
    except Exception, e:
      conn.close()
      print "Connection closed"
      return


    if data.keys()[0] == 'HRHomeStationsRequest':
      ids = data.values()[0]

      ips = list()

      for id in ids:
        ips.append(self.finder.find(id.values()[0]))

      conn.sendall(self.buildRequestResponse(ids,ips))
      conn.close()
    elif data.keys()[0] == 'HRHomeStationUpdate':
      
      id = data.values()[0].values()[0]

      ip = data.values()[0].values()[1]

      self.finder.update(id,ip)

      conn.sendall(id + " " + ip)
      conn.close()
    else:
      conn.close()
      print "Connection closed"

  def buildRequestResponse(self,ids,ips):
    values = list()

    i = 0
    while i < len(ids):
      values.append({'StationDID':ids[i].values()[0], 'StationIP':ips[i]})
      i += 1

    return json.dumps({'HRHomeStationReply':values})
#end Server
