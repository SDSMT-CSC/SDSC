import sys
import os
import resource
from server import Server

def main():
  # id = 0
  # try:
  #   id =  os.fork()
  #   print 'forked'
  # except OSError, e:
  #   print e
  #   sys.exit(1)

  # if id != 0:
  #   sys.exit(0)

  # print 'parent process ended'

  # os.setsid()


  server = Server()
  server.run()

#end main

if __name__ == '__main__':
  main()
