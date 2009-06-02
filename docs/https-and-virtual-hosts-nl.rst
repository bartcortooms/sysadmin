Virtual Hosting op 1 IP adres is 
een probleem bij websites die HTTPS gebruiken. HTTPS is een
protocol waarbij eerst een SSL verbinding wordt opgezet tussen de
webserver en de webbrowser (de laag die voor de encryptie zorgt),
en waar vervolgens het HTTP verkeer overheen gestuurd wordt.

Bij het opzetten van de SSL verbinding presenteert de server een
SSL certificaat aan de client, de webbrowser. De client kan aan de
hand van dat server certificaat bepalen of het inderdaad de juiste
server is waar de client mee praat, en niet iemand die zich
voordoet als de webserver. Nu negeren de meeste gebruikers
(meestal terecht) de waarschuwing van de browser die aangeeft dat
iemand zich mogelijk voordoet als de server, waardoor het hele
certificaat-gedoe voor dat doel vrij nutteloos is, maar dat
terzijde.

Normaal gesproken heeft elk domein een eigen SSL certificaat: het
domein webmail.example.nl heeft dan dus een ander SSL certificaat
dan intranet.example.nl.

Bij het opzetten van een SSL verbinding zal de webserver op een of
andere manier moeten bepalen welk certificaat aan de client
gepresenteerd wordt. Omdat het opzetten van de SSL verbinding
gebeurt nog *voordat* het eerste HTTP verkeer begint, kan de
webserver in dit stadium nog niet weten welke webpagina de client
heeft opgevraagd en dus welk certificaat de server moet kiezen.

Nu is er een makkelijke manier om dit probleem op te lossen: geef
elke website die HTTPS gebruikt een eigen IP adres. De server kan
dan aan de hand van het IP adres waar de SSL verbinding op
binnenkomt bepalen welke website erop draait, en dus welk
certificaat er gekozen moet worden.  Geen ideale oplossing zolang
we het moeten doen met de steeds schaarser wordende verzameling
vrije IPv4 adressen.

Een andere oplossing is om een certificaat te maken dat voor
meerdere domeinen gebruikt kan worden: een wildcard
certificaat.  Daarbij wordt er domeinnaam met een wildcard
(een asterisk) in het certificaat gezet.  *.example.nl is
bijvoorbeeld geldig voor alle domeinnamen onder example.nl.
Daarmee wordt het wel mogelijk om meerdere https websites aan
1 IP adres te hangen, omdat de server dan altijd gewoon
hetzelfde certificaat aan de client presenteert.

Oudere versies van Firefox gaven nog een waarschuwing bij het
gebruik van wildcard certificaten, maar in ieder geval de laatste
versie van Firefox en ook Internet Explorer 6 doen er niet
moeilijk over.
