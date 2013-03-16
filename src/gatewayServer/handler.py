import SocketServer, json
import serial
import core
import hashlib
import time

def NAK (message):
  return json.dumps({'NAK': message})

def ACK (message, DeviceID, data = 0, type = 'Str'):
  return json.dumps({'HRDeviceRequest': {"HumanMessage":message, "Data":data, "Type":type, "DeviceID":DeviceID}})

class handler (SocketServer.BaseRequestHandler):
  '''
  Handles events for the gateawy's SocketServer-derived class. Essentially
  allows individual requests to be handled by a single thread rather than having
  to keep track of each event in serial. This helps substantially with 
  scalability, and prevents a particularly slow request from causing a hangup.
  '''

  def handle(self):
    dev = lambda:0
    time.sleep(1)
    self.request.send('''{"DDNSConnected":[{"Connected":true}]}''')
    request_str = self.request.recv(512+127);
    print(request_str)
    try:
      request = json.loads(request_str);
    except ValueError:
      request = NAK('Invalid JSON received.')
      self.request.send(request)
      return

    if 'HRLoginPassword' in request.keys():
      response = request['HRLoginPassword']
      print response
      passwords = []
      for user in core.users.keys():
        passwords.append(hashlib.sha512(core.users[user]['password']).hexdigest())
      print passwords[0]
      if response in passwords:
        response = '{"RHLoginSuccess" : true,'
        sections = core.devices.keys()
        response += '"RHDeviceCount" : %d, "RHDeviceList":[' % len(sections)
        i = 0
        for device in sections:
          i += 1
          try:
            iface = core.devices[device]
          except KeyError:
            print("Error: %s is not a valid device."%device)
          try:
            if not iface['lock'].acquire(0):
              error_code = (-2, "Device is being read.")
            else:
              error_code = iface['error']
              iface['lock'].release();
          except KeyError:
            print('Error: You need to check your dicts.')
            print(iface.keys())
          try:
            response += '{"DeviceName":"%s", "DeviceSerial":"%s","DeviceTypeCode":%d,"ErrorCode":%d}' % (device, device, int(core.devices[device]['devicetype']), int(error_code[0]))
          except KeyError:
            print('Error: Device Type missing.')
            print(core.devices[device])
          except ValueError:
            print('Oops. Cannot convert to number:')
            print(core.devices[device]['devicetype'])
            print(error_code)
          if i == len(sections):
            response += ']}'
          else:
            response += ','
      else:
        response = '{"RHLoginSuccess" : false}'
      self.request.send(response)
      return
    else:
      try:
        request = request['HRDeviceRequest']
        try:
          dev.requested = request['DeviceID']
        except KeyError:
          response = NAK('Missing DeviceID field')
          self.request.send(response)
          return
        try:
          dev.interface = core.devices[dev.requested]
          dev.value = request['Data']
          dev.datatype = request['Type']
          response = self.handle_request(dev)
        except KeyError:
          response = NAK('Device Not Found or malformed expression.')
          self.request.send(response)
          return
      except KeyError:
        response = NAK('Not a valid request.')
      self.request.send(response)

  def handle_request(self, device):
    # Each interface consists of a name and a lock. The lock prevents multiple
    # reads from each interface, but slow interfaces may take a while. C'est la
    # vie, no way around that, really. Acquire the lock before playing with the
    # interface, and release it when finished.
    device.interface['lock'].acquire()
    try:
        stream = serial.Serial(device.interface['interface'], timeout=0.85, baudrate=9600)
        stream.write("\1")
        stream.flush()
        result = stream.read(1)
        # If we got NAK from the device, something has gone wrong. Send the 
        # error message back to the user as a NAK. If all went well, we don't 
        # care about the response value. Read it and ignore.
        if result == 0:
            result = NAK(stream.read(127))
        else:
            result = stream.read(127)
            if device.datatype == 'Int':
                stream.write(int(device.value))
                result = stream.read(1)
                if result == 0:
                    result = NAK(stream.read(127))
                else:
                    result = ACK(stream.read(127))
            elif device.datatype == 'Str':
                stream.write(str(device.value))
                result = stream.read(1)
                if result == 0:
                    result = NAK(stream.read(127))
                else:
                    result = ACK(stream.read(127), device.requested, result)
            else:
                result = NAK('Malformed data type field. (Expected String or Int)')
    finally:
      device.interface['lock'].release()
    return result
