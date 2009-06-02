The DRAC (Dell Remote Access Controller) interface is a remote management card
which can be used to reset the server, power it down, power it up, or get a
remote view of the console.

The web interface uses a Java applet which only works with Internet Explorer,
which makes the Telnet interface more useful. (Although unfortunately that does
mean the connection is unencrypted!)

The username of the DRAC account is 'root'. You can remotely connect to the
(text) console of the server with the command 'connect video'::

  $ telnet 10.10.10.1
  Trying 10.10.10.1...
  Connected to 10.10.10.1
  Escape character is '^]'.

  Dell Remote Access Card III/XT (DRAC III/XT)
  Firmware Version 3.20 (Build 10.25)
  Login: root
  Password:
  [root]# connect video

To close the session you type ',./' and then 'exit'.
