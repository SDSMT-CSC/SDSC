import json, socket, time, uuid
from threading import Timer

class Remote_Update:
    def update_gateway(self):
        print("Connecting to %s at %d" % self.remote)
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect(self.remote);
            time.sleep(1)
            data = sock.recv(4096)
            if data == '{"DDNSConnected":[{"Connected":true}]}':
                sock.send('{"HRHomeStationUpdate":{"StationDID":"(%s)"}}' % self.localname);

        except socket.error as oops:
            print('Error %s occurred when connecting to %s on port %s.' % (oops, self.remote[0], self.remote[1]))
        else:
            sock.shutdown(socket.SHUT_RDWR)
        finally:
            sock.close()
            self.timer = Timer(30.0, self.update_gateway)
            self.timer.daemon = True
            self.timer.start();

    def __init__(self, remote = ('localhost', 8128) ):
        # Get the mac address for the local machine.
        self.localname = uuid.getnode();
        self.remote = remote;
        self.timer = Timer(3.0, lambda: 1)
        self.timer = Timer(3.0, self.update_gateway)
        self.timer.daemon = True
        self.timer.start();
