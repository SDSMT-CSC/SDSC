import handler
import remote_update
import SocketServer
import core

core.read_cfg()
class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer): pass
keepup = True;
while keepup:
  try:
    server = ThreadedTCPServer(('',8128), handler.handler)
    server.daemon_threads = True;
    remote_update.Remote_Update(('192.168.1.20',8128))
    server.serve_forever()
  except BaseException as e:
    print('Something happened to cause the program to exit. %s' % e.message)
    keepup = False;
  except socket.error:
    pass;
  finally:
    server.shutdown()
    core.write_cfg()
    keepup = False;
