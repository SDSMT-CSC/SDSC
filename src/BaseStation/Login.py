#-------------------------------------------------------------------------------
# Name:        Login
# Purpose:     This function will read in a username/password file, and display
#              a login screen.
#
# Author:      Brian Vogel
#
# Created:     26/02/2013
# Copyright:   (c) 1886327 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import hashlib
try:
    import tkinter as tk
except ImportError:
    import Tkinter as tk

first = True
pw = ""

def Login():
    passwords = [("", "" )]
    password_file = open("users.txt")
    for line in password_file:
        passwords.append( tuple(line.rstrip().split(", ")) )
    passwords.remove(("", "" ))




    def Hash_Password(pw):
        pw_bytes = pw.encode("utf-8")
        return hashlib.sha512(pw_bytes).hexdigest()


    def Make_Entry(parent, caption, width=None, **options):
        tk.Label(parent, text=caption).pack(side=tk.TOP)
        entry = tk.Entry(parent, **options)
        if width:
            entry.config(width=width)
        entry.pack(side=tk.TOP, padx=10, fill=tk.BOTH)
        return entry

    def enter(event):
        check_password()

    def check_password():
        Hash_pw = Hash_Password(password.get())
        if(username.get(), Hash_pw) in passwords:
            #check_password.username = username.get()
            Login_Window.destroy()
            global pw
            pw = Hash_pw
            return

        global first
        if first is True:
            tk.Label(parent, text="Incorrect Username or Password").pack(side=tk.TOP)
            first=False

    Login_Window = tk.Tk()
    Login_Window.geometry("300x180")
    Login_Window.title("Login")

    #Frame window with margin
    parent = tk.Frame(Login_Window, padx=10,pady=10)
    parent.pack(fill=tk.BOTH, expand=True)

    #entrys with not show text
    username = Make_Entry(parent, "Username", 16, show='')
    password = Make_Entry(parent, "Password", 16, show='*')

    #Button to attempt to login
    Login_Button = tk.Button(parent, borderwidth=4, text="Login", width=10, pady=8, command=check_password)
    Login_Button.pack(side=tk.BOTTOM)
    password.bind("<Return>", enter)

    username.focus_set()
    parent.mainloop()

    return pw

if __name__ == '__main__':
    Login()