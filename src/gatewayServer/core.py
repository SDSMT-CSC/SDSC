device_file = 'devices.ini'
user_file = 'users.ini'

import ConfigParser
import threading
import serial

dev_cfg = ConfigParser.ConfigParser()
usr_cfg = ConfigParser.ConfigParser()
devices = {}
users = {}

def read_cfg():
  global devices
  global users
  global usr_cfg
  global dev_cfg
  dev_cfg.read(device_file)
  for device in dev_cfg.sections():
    options = dev_cfg.items(device)
    devices[device] = dict(options)
    devices[device]['lock'] = threading.RLock()
    try:
      interface = serial.Serial(devices[device]['interface'], timeout=1, baudrate=9600)
    except:
      print("Failed to open file %s." % devices[device]['interface']);
      devices[device]['error'] = (1, "Device is offline or bad interface specified.")
    else:
      interface.write("\0")
      interface.flush()
      retval = interface.read(1)
      if retval == '':
        retval = 0
      else:
        retval = int(retval)
      devices[device]['error'] = (retval, interface.read(interface.inWaiting()))
  print('Done loading devices.')

  usr_cfg.read(user_file)
  for user in usr_cfg.sections():
    options = usr_cfg.items(user)
    users[user] = dict(options)

def sync_cfg():
  '''
    Force the configuration objects to re-read the users and devices dicts, and
    update the configuration objects to reflect what's stored there. This should
    be called before saving a configuration change to disk.
  '''
  # First, update all missing devices in the device config file.
  for device in devices.keys():
    if not dev_cfg.has_section(device):
      dev_cfg.add_section(device)
    for option,val in devices[device]:
      # Don't keep locks in the config file. That just wouldn't work.
      if option != 'lock':
        dev_cfg.set(device, option, val)
  # Next, remove devices removed from the devices dict from the config file.
  for device in dev_cfg.sections():
    if device not in devices.keys():
      dev_cfg.remove_section(device)
  # Do the same for the users.
  for user in users.keys():
    if not usr_cfg.has_section(user):
      usr_cfg.add_section(user)
    for option, val in users[user]:
      usr_cfg.set(user, option, val)
  for user in usr_cfg.sections():
    if user not in users.keys():
      usr_cfg.remove_section(user)

def write_cfg():
  usr_cfg.write(open(user_file, 'w'))
  dev_cfg.write(open(device_file, 'w'))
