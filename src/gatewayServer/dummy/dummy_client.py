import socket

ip = raw_input('Please enter the target.\n');
quit = False;
while(quit == False):
  try:
    line = raw_input('Please enter a string to be passed to the server, or Ctrl-C to quit.\n')
  except EOFError as e:
    quit = True;
  except KeyboardInterrupt:
    quit = True;
  else: 
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
      sock.connect((ip,8128))
    except socket.error as e:
      print('Failed to connect to %s on port 8128.' % ip)
    else:
      sock.recv(4096);
      sock.send(line)
      response = sock.recv(4096)
      print("%s\n%s\n" % (line, response))
