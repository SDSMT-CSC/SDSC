import handler
import remote_update
import SocketServer
import core

core.read_cfg()
class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer): pass
server = ThreadedTCPServer(('Geat',8128), handler.handler)
server.daemon_threads = True;
remote_update.Remote_Update(('172.20.10.2',8128))
try:
  server.serve_forever()
except BaseException as e:
  print('Something happened to cause the program to exit. %s' % e.message)
finally:
  server.shutdown()
  core.write_cfg()
