import socket
import json
import time
from finder import Finder

################################################################################
#Class: Server
#Purpose: the ddns server, handles requests to get IP addresses for devices,
#         to update the IP address of a device, or add a new device
#Author: Joshua Kinkade
#Date: April 13, 2013
################################################################################
class Server:

  ################################################################################
  #Method: init
  #Description: initializes an instance of a Server
  #Parameters: self - the Server instance
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  #################################################################################
  def __init__(self):
    #initializes properties
    self.hostName = socket.gethostname()
    #self.hostName = 'localhost'
    self.port = 8128
    self.finder = Finder('deviceServer.db')

  #end __init__


  ################################################################################
  #Method: run
  #Description: runs the server
  #Parameters: self - the Server instance
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  #################################################################################
  def run(self):
    #get port to listen to
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((self.hostName, self.port))
     
    #listen forever
    while 1:
      s.listen(5)

      #get a connection
      conn, addr = s.accept()

      #send connection to connection handler
      self.handleConnection(conn,addr)

    s.close()
  #end run

  ################################################################################
  #Method: handleConnection
  #Description: Handles a single connection
  #Parameters: self - the Server instance
  #            conn - the connection
  #            addr - the IP address of the client
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  #################################################################################
  def handleConnection(self,conn,addr):
    time.sleep(1) #wait for the connection to fully establish

    #confirm the connection with the client
    conn.send('''{"DDNSConnected":[{"Connected":true}]}''')

    #recieve data from the client
    raw = conn.recv(4096)

    data = None

    #try to parse the data as json, if that fails give up and close the connection
    try:
      data = json.loads(raw)
    except Exception, e:
      print "JSON error"
      conn.close()
      return

    #check the data for validity again
    try:
      data.keys()
    except Exception, e:
      print "Bad request 1"
      conn.close()
      return

    if data.keys()[0] == 'HRHomeStationsRequest': #get ids for ips

      print "Home Stations Request"


      ids = data.values()[0]

      #make sure client provided ids
      if len(ids) == 0:
        conn.close()
        return

      ips = list()

      #get the IP address for each id listed
      for id in ids:
        try:
          ips.append(self.finder.find(id.values()[0]))
        except Exception, e: #if there was an error with the request, close th connection
          print "Bad request 2"
          conn.close()
          return

      #build a response and send it to the client
      conn.sendall(self.buildRequestResponse(ids,ips))
      conn.close()
    #updating an IP Address or add a new device to the database
    elif data.keys()[0] == 'HRHomeStationUpdate':
      
      try: 
        id = data.values()[0].values()[0]

        #ip = data.values()[0].values()[1]
        ip = addr[0] #get IP address

        print ip

        self.finder.update(id,ip) #update in database
      except Exception, e: #if there was an error with the request close the connection
        print "Bad request 3"
        conn.close()
        return

      conn.sendall(id + " " + ip) #send back id and ip as plain text
      conn.close()
    else: #if the request is not recognized, just close the connection
      conn.close()

  ################################################################################
  #Method: buildRequestResponse
  #Description: builds a response for an HRHomeStationsRequest
  #Parameters: self - the Server instance
  #            ids - the device ids sent with the request
  #            ips - the IP addresses of the devices requested
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  #################################################################################
  def buildRequestResponse(self,ids,ips):
    values = list() #create an empty list

    #add each id and ip to the list
    i = 0
    while i < len(ids): 
      values.append({'StationDID':ids[i].values()[0], 'StationIP':ips[i]})
      i += 1

    #create the response object, serialize into json, and send it to the client
    return json.dumps({'HRHomeStationReply':values})
#end Server
