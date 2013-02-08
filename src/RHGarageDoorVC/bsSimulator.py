import socket
import time
import sys

def main():
  if len(sys.argv) != 2:
    print "Incorrect arguments"
    return

  return_value = 0

  if sys.argv[1] == "success":
    return_value = 1
  elif sys.argv[1] == "fail":
    return_value = 0
  else:
    print "Command not found"
    return;

  runserver(return_value)


def runserver(return_value):
  soc = socket.socket()

  soc.bind((socket.gethostname(),8128))

  soc.listen(5)

  conn, addr = sco.accept()
  


if __name__ == '__main__':
  main()
