import sqlite3

class Finder:
  def __init__(self,dbFile):
    self.dbFile = dbFile
    self.db = sqlite3.connect(self.dbFile)
  #end __init__

  def find(self, deviceID):

    cursor = self.db.cursor()

    cursor.execute('SELECT IP FROM devices WHERE ID=?',[deviceID])

    ip = cursor.fetchall()

    if len( ip ) == 0:
      return None

    ip = ip[0][0]

    self.db.commit()
    cursor.close()

    return ip
  #end find

  def update(self, deviceID, deviceIP):

    cursor = self.db.cursor()

    cursor.execute('SELECT * FROM devices WHERE ID=?', [deviceID])

    if len(cursor.fetchall()) is 0:
      cursor.execute('INSERT INTO devices VALUES(?,?)',(deviceID,deviceIP))
    else:
      cursor.execute('UPDATE devices SET IP=? WHERE ID=?',(deviceIP, deviceID))

    self.db.commit()
    cursor.close()
  #end update
