De database van Zope wordt de ZODB genoemd, wat staat voor Zope Object
DataBase. De ZODB is waar Zope al haar data opslaat die bewaard moet blijven
als Zope opnieuw gestart wordt. Het is geen standaard relationele database,
maar een object-georiënteerde database.

Python, de voornaamste scripttaal binnen Zope, is ook object-georiënteerd. De
ZODB kan gebruikt worden om objecten die in Python zijn gecreëerd te bewaren op
een vast medium, zoals een harde schijf.

Om aan te geven wanneer dat nuttig zou kunnen zijn, is hier een voorbeeld van
een simpele Python class::

  class Boek:
      def __init__(self, titel="", auteur="", uitgever="", isbn=""):
          self.titel = titel
          self.auteur = auteur
          self.uitgever = uitgever
          self.isbn = isbn
	  self.aantal_paginas = 0

Stel dat je een nieuw object van deze class aanmaakt op de volgende manier::

  python_boek = Boek("Learning Python", "Mark Lutz", "O'Reilly", "1-56592-464-9")
  python_boek.aantal_paginas = 382

Om deze gegevens op te kunnen slaan, zou je een stuk code kunnen schrijven dat
alle waarden van de attributen van het object opslaat in een bestand. Maar
Python heeft daar standaard al een makkelijkere manier voor: de pickle module.

Een object opslaan met de pickle module kan op de volgende manier::

  bestand = open('boekgegevens', 'w')
  pickle.dump(python_boek, bestand)
  bestand.close()

Het bestand boekgegevens kan nu bijvoorbeeld naar een andere computer worden
gekopieerd en daar weer opgevraagd worden met::

  f = open('boekgegevens')
  boek = pickle.load(f)

De ZODB maakt gebruikt van deze pickle module. De objecten worden door de ZODB
in gepicklede vorm opgeslagen - meestal in een bestand op de harde schijf, maar
het kan ook een BerkeleyDB zijn, of een relationele database zoals Oracle.

Het voordeel van het gebruik van de ZODB is dat het opslaan van gegevens
volledig transparant wordt voor de applicatie. Bij het afsluiten van een Python
applicatie die een ZODB gebruikt, worden alle objecten, inclusief hun
attributen, automatisch opgeslagen. Bij het starten van de applicatie wordt de
ZODB weer geopend en is het object inclusief de waarden van zijn attributen
weer beschikbaar.

Om een ZODB in een Python applicatie te kunnen gebruiken, moet er eerst een
verbinding met de database geopend worden. Dat kan al met 4 regels code::

  from ZODB import FileStorage, DB

  storage = FileStorage.FileStorage('/tmp/filestorage.fs')
  db = DB(storage)
  conn = db.open()

Nu de database is geopend, kunnen er objecten aan worden toegevoegd. Eerst moet
daarvoor het root object opgevraagd worden. Het root object is een 'container',
het object dat alle andere objecten in de ZODB bevat::

  # Vraag het root object van de ZODB op in en bewaar 'm in een variable
  dbroot = conn.root()

Aan dbroot kunnen nu de objecten worden toegevoegd die in de ZODB moeten worden
opgeslagen.

Om dit te laten werken voor de class Boek, moet die eerst nog persistent
gemaakt worden. Zo kan Zope bijhouden wanneer er veranderingen in het object
optreden. Een class kan persistent gemaakt worden door 'm met de Persistent
class te mixen.

Boek komt er na het mixen met de class Persistent zo uit te zien::

  import ZODB
  from Persistence import Persistent

  class Boek(Persistent):
      def __init__(self, titel="", auteur="", uitgever="", isbn=""):
          self.titel = titel
          self.auteur = auteur
          self.uitgever = uitgever
          self.isbn = isbn
	  self.aantal_paginas = 0

Nu kan er bijvoorbeeld een lijst van boeken toegevoegd worden aan de ZODB::

  # Bouw een lijst van boeken op
  boeken = []
  boeken.append(Boek("Learning Python", "Mark Lutz", "O'Reilly"))
  boeken.append(Boek("Programming Python", "Mark Lutz", "O'Reilly"))
  boeken.append(Boek("TCP/IP Illustrated Volume 1", "W. Richard Stevens")

  # Voeg de lijst toe aan de ZODB
  dbroot['boeken'] = boeken

Om de veranderingen in de ZODB door te voeren moet de transactie eerst nog
definitief worden gemaakt::

  get_transaction().commit()

Doordat alle objecten in de ZODB gebruik maken van de Persistent class, weet de
ZODB welke objecten er zijn veranderd. Bij de commit van een transactie hoeven
alleen de veranderde objecten bijgewerkt te worden in de database.

Om de ZODB te gebruiken in Zope hoeft er niets speciaals gedaan te worden.
Folders, documenten, plaatjes en scripts zijn allemaal objecten die zich in de
ZODB van Zope bevinden. Een Python script is bijvoorbeeld een attribuut van een
Folder object, en een Folder object weer een attribuut van een hoger gelegen
folder. Uiteindelijk komen ze allemaal samen in het root object van de ZODB.

Ook objecten die in scripts worden gecreëerd worden in de ZODB geplaatst - de
standaard classes die Zope aanbiedt zijn allemaal al persistent. Het committen
van transacties gebeurt vanzelf, Zope doet dit aan het eind van elke HTTP
request.
