import SocketServer, json
import serial
import core
import hashlib
import time
import re

is_ip = re.compile('(\d{1,3}\.){3,3}?\d{1,3}')

def NAK (message):
  return json.dumps({'NAK': message})

def ACK (data, DeviceID, message = '', type = 'Str'):
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
      passwords = {}
      for user in core.users.keys():
        passwords[hashlib.sha512(user).hexdigest()] = core.users[user]['group']
      if response in passwords.keys():
        group = passwords[response];
        print passwords.keys()
        response = '{"RHLoginSuccess" : true,'
        sections = core.devices.keys()
        length = 0;
        response += '"RHDeviceList":['
        i = 0
        for device in sections:
          i += 1
          try:
            iface = core.devices[device]
          except KeyError:
            print("Error: %s is not a valid device."%device)
          try:
            if not iface['lock'].acquire(0):
              error_code = (-2, "Device is in use.")
            else:
              error_code = iface['error']
              iface['lock'].release();
          except KeyError:
            print('Error: You need to check your dicts.')
            print(iface.keys())
          if(group == iface['group'] or group.lower() == 'all'):
            length += 1;
            try:
              response += '{"DeviceName":"%s", "DeviceSerial":"%s","DeviceType":%d,"ErrorCode":%d}' % (device, device, int(core.devices[device]['devicetype']), int(error_code[0]))
            except KeyError:
              print('Error: Device Type missing.')
              print(core.devices[device])
            except ValueError:
              print('Oops. Cannot convert to number:')
              print(core.devices[device]['devicetype'])
              print(error_code)
              response += '{"DeviceName":"%s", "DeviceSerial":"%s","DeviceType":%s,"ErrorCode":%d}' % (device, device, core.devices[device]['devicetype'], int(error_code[0]))
            if i == len(sections):
              response += '],'
              response += '"RHDeviceCount": %d}' % length
            else:
              response += ','
        if length == 0:
          response += '], RHDevicesCount:0}';
      else:
        response = '{"RHLoginSuccess" : false}'
      print response;
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
        if 'Password' not in request.keys() or request['Password'] == "":
          response = NAK('Missing Password field.');
          self.request.send(response);
          return
        # Validate the passwords
        password = request['Password'];
        passwords = {};
        for user in core.users.keys():
          passwords[hashlib.sha512(user).hexdigest()] = core.users[user]['group']
        if password not in passwords.keys():
          self.request.send(NAK('Invalid Password.'));
          return
        else:
          group = passwords[password];
          if group.lower() != 'all' and group != core.devices[dev.requested]['group']:
            self.request.send(NAK('%s does not have access to device %s.' % (password, dev.requested)));
            return
        # Password validated. Compress everything and send it to request-handling function.
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
      print(response);
      self.request.send(response)

  def handle_request(self, device):
    # If we have an IPV4 address, send on socket instead of file.
    global is_ip;
    if (is_ip.match(device.interface['interface']) is not None):
      stream = socket.socket(socket.AF_INET);
      try:
        stream.connect((device.interface['interface'], 8128));
        stream.send("\1");
        result = stream.recv(1);
        stream.send(device.value);
        return ACK(stream.recv(127), device.connected, result);
      except socket.error as e:
        print('Error: failed to connect to %s on port 8128: %s' % (device.interface['interface'], e));
        return NAK('Failed to connect.');
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
                    result = ACK(stream.read(127), device.requested, result)
            elif device.datatype == 'Str':
                stream.write(str(device.value))
                result = stream.read(1)
                if result == 0:
                    result = NAK(stream.read(127))
                else:
                    result = ACK(stream.read(127), device.requested, result)
            else:
                result = NAK('Malformed data type field. (Expected String or Int)')
    except serial.SerialException as e:
      result = NAK('Failed to access interface %s (Bad interface or not connected).' % device.interface['interface']);
    finally:
      device.interface['lock'].release()
    return result
