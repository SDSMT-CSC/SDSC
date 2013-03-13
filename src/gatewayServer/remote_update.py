import json, socket, time, uuid
from threading import Timer

class Remote_Update:
    def update_gateway(self):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect(self.remote);
            time.sleep(1)
            data = sock.recv(4096)
            if data == '''{"DDNSConnected":[{"Connected":true}]}''':
                sock.send('''{"HRHomeStationUpdate":{"StationDID":"(%s)"}}''' % self.localname);

        except socket.error as oops:
            print('Error %s occurred when connecting to %s on port %s.' % (oops.message, self.remote[0], self.remote[1]))
        else:
            self.timer.start();
            sock.shutdown(socket.SHUT_RDWR)
        finally:
            sock.close()

    def __init__(self, remote = ('localhost', 8128) ):
        # Get the mac address for the local machine.
        self.localname = uuid.getnode();
        self.remote = remote;
        self.timer = Timer(300.0, lambda: 1)
        self.timer = Timer(300.0, self.update_gateway())
        self.timer.start();
        
if __name__=='__main__':
    Remote_Update()
