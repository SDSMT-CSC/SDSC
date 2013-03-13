import handler
import remote_update
import SocketServer
import core

core.read_cfg()
server = SocketServer.TCPServer(('localhost',8128), handler.handler)
try:
  server.serve_forever()
except BaseException as e:
  print('Something happened to cause the program to exit. %s' % e.message)
finally:
  core.write_cfg()
