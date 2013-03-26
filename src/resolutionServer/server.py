import socket
import json
import time
from finder import Finder

class Server:
  def __init__(self):
    self.hostName = socket.gethostname()
    #self.hostName = 'localhost'
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
    time.sleep(1)
    conn.send('''{"DDNSConnected":[{"Connected":true}]}''')

    raw = conn.recv(4096)

    data = None

    try:
      data = json.loads(raw)
    except Exception, e:
      print "JSON error"
      conn.close()
      return

    try:
      data.keys()
    except Exception, e:
      print "Bad request 1"
      conn.close()
      return

    if data.keys()[0] == 'HRHomeStationsRequest':

      print "Home Stations Request"

      ids = data.values()[0]

      ips = list()

      for id in ids:
        try:
          ips.append(self.finder.find(id.values()[0]))
        except Exception, e:
          print "Bad request 2"
          conn.close()
          return

      conn.sendall(self.buildRequestResponse(ids,ips))
      conn.close()
    elif data.keys()[0] == 'HRHomeStationUpdate':
      
      try:
        id = data.values()[0].values()[0]

        #ip = data.values()[0].values()[1]
        ip = addr[0]

        print ip

        self.finder.update(id,ip)
      except Exception, e:
        print "Bad request 3"
        conn.close()
        return

      conn.sendall(id + " " + ip)
      conn.close()
    else:
      conn.close()

  def buildRequestResponse(self,ids,ips):
    values = list()

    i = 0
    while i < len(ids):
      values.append({'StationDID':ids[i].values()[0], 'StationIP':ips[i]})
      i += 1

    return json.dumps({'HRHomeStationReply':values})
#end Server
