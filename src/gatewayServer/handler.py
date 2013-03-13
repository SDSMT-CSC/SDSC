import SocketServer, json
import serial
import core

def NAK (message):
  return json.dumps({'NAK': {message}})

def ACK (message):
  return json.dumps({'ACK': {message}})

class handler (SocketServer.BaseRequestHandler):
  '''
  Handles events for the gateawy's SocketServer-derived class. Essentially
  allows individual requests to be handled by a single thread rather than having
  to keep track of each event in serial. This helps substantially with 
  scalability, and prevents a particularly slow request from causing a hangup.
  '''
  def handle(self):
    request_str = self.request.recv(4096);
    request = json.loads(request_str);
    try:
      dev.requested = request['DeviceDID']
    except KeyError:
      response = NAK('Missing DeviceDID field')
    try:
      dev.interface = config.devices[dev.requested]
      dev.value = request['Data']
      dev.datatype = request['Type']
      response = handle_request(dev)
      
    except KeyError:
      response = NAK('Device Not Found or malformed expression.')
    self.request.send(response)

  def handle_request(self, device):
    # Each interface consists of a name and a lock. The lock prevents multiple
    # reads from each interface, but slow interfaces may take a while. C'est la
    # vie, no way around that, really. Acquire the lock before playing with the
    # interface, and release it when finished.
    device.interface['lock'].acquire()
    try:
        stream = open(device.interface['interface'], 'r+')
        stream.write("\1")
        stream.flush()
        result = stream.read(1)
        # If we got NAK from the device, something has gone wrong. Send the 
        # error message back to the user as a NAK. If all went well, we don't 
        # care about the response value. Read it and ignore.
        if result == 0:
            result = NAK(stream.read(4096))
        else:
            result = stream.read(4096)
            if device.datatype == 'Int':
                stream.write(int(device.data))
                result = stream.read(1)
                if result == 0:
                    result = NAK(stream.read(4096))
                else:
                    result = ACK(stream.read(4096))
            elif device.datatype == 'String':
                stream.write(str(device.data))
                result = stream.read(1)
                if result == 0:
                    result = NAK(stream.read(4096))
                else:
                    result = ACK(stream.read(4096))
            else:
                result = NAK('Malformed data type field. (Expected String or Int)')
    finally:
        device.interface['lock'].release()
