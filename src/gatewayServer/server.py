import handler
import remote_update
import SocketServer
import core

core.read_cfg()
class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer): pass
server = ThreadedTCPServer(('localhost',8128), handler.handler)
try:
  server.serve_forever()
except BaseException as e:
  print('Something happened to cause the program to exit. %s' % e.message)
finally:
  server.shutdown()
  core.write_cfg()
