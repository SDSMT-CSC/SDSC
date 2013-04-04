import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

ip = raw_input('Please enter the target.\n');
line = raw_input('Please enter a string to be passed to the server.\n')
try:
  #ip = '151.159.200.25'
  sock.connect(( ip,8128))
except socket.error as e:
  print('Failed to connect to %s on port 8128.' % ip)
else:
  sock.recv(4096);
  sock.send(line)
  response = sock.recv(4096)
  print(response)
