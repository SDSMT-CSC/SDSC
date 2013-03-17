import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

line = raw_input('Please enter a string to be passed to the server.\n')
try:
  ip = '70.198.6.251'
  sock.connect(( ip,8128))
except socket.error as e:
  print('Failed to connect to 70.198.6.251 on port 8128.')
else:
  sock.send(line)
  response = sock.recv(4096)
  print(response)
