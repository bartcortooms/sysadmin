SSL (en TLS) maakt gebruik van public key encryption. Alle services die een SSL
verbinding aanbieden, zoals Apache en OpenLDAP, hebben daarom een keypaar
nodig, bestaande uit een private key en een public key. Een service hoeft maar
1 keypaar te hebben, ook wanneer er voor een service meerdere certificaten
worden gebruikt (zoals bij Apache).

Bij het aanmaken van een certificaat wordt de public key, samen met nog wat
andere informatie zoals de domeinnaam, gesigned met de private key van de
service. De signature wordt vervolgens gecombineerd met de public key en de
informatie over het certificaat. Het resultaat is een certificate request.

Een certificate request is pas een geldig SSL certificaat als deze ook nog
gesigned is met de private key van een Certificate Authority (CA). Omdat we
geen 50 dollar per jaar willen betalen voor een certificaat, spelen we onze
eigen CA.

Als een service nog geen private key heeft, dan kan die gegenereerd worden met
openssl. Let erop dat de private key **alleen** leesbaar is voor de userid
waarmee de service de key opent. Dit voorbeeld gaat uit van Apache, die de key
als root opent. De onderstaande umask aanroep voorkomt dat de private key
leesbaar is voor anderen. Door het commando samen met de openssl aanroep binnen
( ) tekens te zetten geldt de umask alleen voor dat commando::

  $ (umask 077; openssl genrsa -out serverkey.pem 1024)
  $ sudo chown root:root serverkey.pem
  $ sudo mv serverkey.pem /etc/apache2/ssl/

Elk domein van Apache heeft een eigen certificaat, omdat in het certificaat de
domeinnaam is opgeslagen. Als voorbeeld maken we hier een certificaat aan voor
de webpagina "webmail.example.nl".

Maak eerst een certificate request aan, op de server waar de service draait (in
dit geval de webserver) en met de private key die bij de service hoort. De
private key van Apache is alleen leesbaar voor root, dus openssl wordt hier met
sudo aangeroepen::

  $ sudo openssl req -new -out webmail.example.nl.pem -key /etc/apache2/ssl/serverkey.pem
  You are about to be asked to enter information that will be incorporated
  into your certificate request.
  What you are about to enter is what is called a Distinguished Name or a DN.
  There are quite a few fields but you can leave some blank
  For some fields there will be a default value,
  If you enter '.', the field will be left blank.
  -----
  Country Name (2 letter code) [NL]:
  State or Province Name (full name) [Noord-Brabant]:
  Locality Name (eg, city) [Eindhoven]:
  Organization Name (eg, company) [ACME Inc]:
  Organizational Unit Name (eg, section) [ICT]:
  Common Name (eg, YOUR name) []:webmail.example.nl
  Email Address []:webmaster@example.nl

  Please enter the following 'extra' attributes
  to be sent with your certificate request
  A challenge password []:
  An optional company name []:

Waar al een standaardwaarde is ingevuld, kan die worden gebruikt. (Deze waarden
komen uit /etc/ssl/openssl.cnf.) Vul bij Common Name de domeinnaam waarop de
service draait in, in dit geval dus 'webmail.example.nl'. Vul geen wachtwoord in
wanneer daar om gevraagd wordt.

Het resultaat van het commando, 'webmail.example.nl.pem', is een certificate
request, die nog gesigned moet worden door de CA om als certificate gebruikt te
kunnen worden. Bevindt de private CA key zich op een andere machine, kopieer de
certificate request dan over met scp::

  $ scp webmail.example.nl.pem srv01.example.nl:

De certificate request kan nu gesigned worden met de private key van de CA.
Daarbij wordt om het CA wachtwoord gevraagd::

  $ sudo mv webmail.example.nl.pem /etc/ssl/requests
  $ sudo chown root:root /etc/ssl/requests/webmail.example.nl.pem
  $ cd /etc/ssl
  $ sudo make
  Using configuration from /usr/lib/ssl/openssl.cnf
  Enter pass phrase for /etc/ssl/private/cakey.pem:
  ...
  Certificate is to be certified until Apr 25 13:41:54 2010 GMT (1825 days)
  Sign the certificate? [y/n]:y


  1 out of 1 certificate requests certified, commit? [y/n]y

De certificate in de directory certs/ is nu klaar voor gebruik en kan worden
gekopieerd naar de server waar de service op draait::

  $ scp certs/webmail.example.nl.pem srv03.example.nl:
