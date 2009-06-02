DRACs zijn bereikbaar via Telnet (unencrypted dus!) en HTTPS. De web interface
gebruikt een Java applet die alleen onder Internet Explorer werkt. Met allebei
de interfaces kun je een power down doen, de server resetten en een remote
console opvragen.

DRAC III kaarten werken net iets anders dan DRAC 4 kaarten. Bij de DRAC III
kaart is de gebruikersnaam altijd 'root', omdat het daar niet mogelijk is zelf
accounts toe te voegen. Je maakt de remote console verbinding met 'connect
video' (in plaats van 'connect com2' zoals bij de DRAC 4)::

  $ telnet 10.10.10.1
  Trying 10.10.10.1...
  Connected to 10.10.10.1
  Escape character is '^]'.

  Dell Remote Access Card III/XT (DRAC III/XT)
  Firmware Version 3.20 (Build 10.25)
  Login: root
  Password:
  [root]# connect video

Om de sessie af te sluiten typ je in: ',./' en daarna 'exit'.
