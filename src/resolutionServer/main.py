import sys
import os
from server import Server

def main():
  # id = 0
  # #separate process from the terminal that started it
  # try:
  #   id =  os.fork()
  #   print 'forked'
  # except OSError, e:
  #   #if there was an error while forking exit both processes
  #   print e
  #   sys.exit(1)

  # #if process is not child, exit
  # if id != 0:
  #   sys.exit(0)

  # print 'parent process ended'

  # os.setsid()


  #create and run server
  server = Server() 
  server.run()

#end main

#run main function
if __name__ == '__main__':
  main()
