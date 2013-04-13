import sqlite3

################################################################################
#Method: Finder
#Purpose: takes care of interaction the database so the Server class doesn't
#         have to
#Author: Joshua Kinkade
#Date: April 13, 2013
################################################################################
class Finder:

  ##############################################################################
  #Method: __init__
  #Description: initializes a new Finder instance
  #Parameters: self - the Finder instance
  #            dbFile - the file name of the sqlite database
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  ##############################################################################
  def __init__(self,dbFile):
    self.dbFile = dbFile
    self.db = sqlite3.connect(self.dbFile)
  #end __init__

  ##############################################################################
  #Method: find
  #Description: finds the ip for a given device id
  #Parameters: self - the Finder instance
  #            deviceID - the id to lookup
  #Returns: the ip address for the device or None
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  ##############################################################################
  def find(self, deviceID):

    cursor = self.db.cursor() #get cursor for database

    #run select query
    cursor.execute('SELECT IP FROM devices WHERE ID=?',[deviceID])

    #get results from cursor
    ip = cursor.fetchall()

    #if no ips found return None
    if len( ip ) == 0:
      return None

    ip = ip[0][0]

    #commit database changes and close the cursor
    self.db.commit()
    cursor.close()

    print ip
    return ip
  #end find

  ################################################################################
  #Method: update
  #Description: updates a device's ip address in the database or adds it
  #Parameters: self - the Server instance
  #            deviceID - the device id to update
  #            deviceIP - the new IP address of the device
  #Author: Joshua Kinkade
  #Date: April 13, 2013
  #################################################################################
  def update(self, deviceID, deviceIP):

    #if input data is bad, don't try updating database
    if deviceID == None or deviceIP == None:
      return

    #get a database cursor
    cursor = self.db.cursor()

    #try to get device from database
    cursor.execute('SELECT * FROM devices WHERE ID=?', [deviceID])

    #if device is not in database
    if len(cursor.fetchall()) is 0:
      #add device
      cursor.execute('INSERT INTO devices VALUES(?,?)',(deviceID,deviceIP))
    else:
      #update device's ip address
      cursor.execute('UPDATE devices SET IP=? WHERE ID=?',(deviceIP, deviceID))

    #commit changes and close the cursor
    self.db.commit()
    cursor.close()
  #end update
