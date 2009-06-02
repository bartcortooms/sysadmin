DRACs zijn bereikbaar via Telnet (unencrypted dus!) en HTTPS. De web
interface gebruikt een Java applet die alleen onder Internet Explorer
werkt. Met allebei de interfaces kun je een power down doen, de server
resetten en een remote console opvragen.

De Telnet interface werkt als volgt::

  $ telnet 10.10.10.1
  Trying 10.10.10.1...
  Connected to 10.10.10.1.
  Escape character is '^]'.

  Dell Remote Access Controller 4/I (DRAC 4/I)
  Firmware Version 1.20 (Build 03.15)
  Login: username
  Password: 
  [username]# connect com2

Om de sessie af te sluiten typ je dit in: ',./' en daarna 'exit'.
