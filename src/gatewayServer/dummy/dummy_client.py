import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

line = raw_input('Please enter a string to be passed to the server.\n')
try:
  sock.connect(('Geat',8128))
  sock.read(4096)
except socket.error as e:
  print('Failed to connect to localhost on port 8128.')
else:
  sock.send(line)
  response = sock.recv(4096)
  print(response)
