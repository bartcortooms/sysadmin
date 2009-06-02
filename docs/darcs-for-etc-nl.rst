Hieronder volgt een uitleg over het gebruik van "darcs":http://www.darcs.net/
in /etc, voor wanneer de repository al geconfigureerd is op de server. Als er
nog geen darcs repository is geconfigureerd, lees dan "Darcs voor /etc initialisatie":/installatie/darcs-voor-etc-initialisatie/ om te zien hoe de
repository geinitialiseerd moet worden.

Introductie

  Darcs lijkt veel op CVS, Subversion, Arch en andere software voor
  versiebeheer, maar heeft zo haar eigen eigenaardigheden. De repository staat
  in dezelfde directory als de working directory: sterker nog, de working
  directory *is* de repository. Alle bestanden die darcs nodig heeft voor het
  versiebeheer van de repository staan in de directory '_darcs'. Er is maar 1
  _darcs directory; in het geval van de /etc repository is dat /etc/_darcs. Er
  wordt dus niet in elke subdirectory een _darcs directory aangemaakt, zoals
  CVS en Subversion dat doen.

  Wanneer een bestand in /etc veranderd is, kan die verandering in de
  repository gecommit worden met het darcs commando 'record'. Een commit, of
  record, kan meerdere bestanden beslaan, zodat de veranderingen die logisch
  gezien bij elkaar horen in dezelfde patch opgenomen kunnen worden.

  Stel dat je een aantal configuratiebestanden veranderd hebt en deze wilt
  committen in de repository. Met 'whatsnew' kun je zien welke veranderingen
  er zijn.
  
  Eerst passen we wat bestanden aan::

    $ sudo vi mailname
    $ sudo vi postfix/main.cf
    
  Met 'darcs whatsnew -s' zie je welke bestanden zijn aangepast::
  
    $ darcs whatsnew -s
    M ./mailname -1 +1
    M ./postfix/main.cf -1 +1
  
  Hetzelfde commando maar dan zonder '-s' geeft de volledige wijziging weer::
  
    $ darcs whatsnew
    {
    hunk ./mailname 1
    -srv01.example.nl
    +example.nl
    hunk ./postfix/main.cf 12
    -myhostname = srv01.example.nl
    +myhostname = mail.example.nl
    }

  De optie '-l' laat ook zien welke bestanden zich wel in de directory
  bevinden, maar niet aan de repository toegevoegd zijn::

    $ darcs whatsnew -sl
    M ./mailname -1 +1
    M ./postfix/main.cf -1 +1
    a ./postfix/virtual

  Het opslaan van veranderingen in de repository (committen) doe je onder je
  eigen useraccount. Darcs moet daarvoor een emailadres hebben om aan de
  commits te kunnen koppelen. Dit emailadres zet je in ~/.darcs/author,
  bijvoorbeeld::

    $ cat ~/.darcs/author
    Bart Cortooms <bart@hiccup.nl>

  Nu de veranderingen opslaan in de repository::

    $ darcs record
    hunk ./mailname 1
    -srv01.example.nl
    +example.nl
    Shall I record this patch? (1/2) [ynWsfqadjk], or ? for help: y
    hunk ./postfix/main.cf 12
    -myhostname = srv01.example.nl
    +myhostname = mail.example.nl
    Shall I record this patch? (2/2) [ynWsfqadjk], or ? for help: y
    What is the patch name? srv01 is primary mx
    Do you want to add a long comment? [yn] n
    Finished recording patch 'srv01 is primary mx'

  Darcs vraagt standaard bij elke verandering of deze bij de patch hoort. Op
  die manier kun je, als het bestand verder nog veranderingen heeft die niet
  bij de patch horen, sommige wijzigingen in het bestand overslaan, zodat de
  patch 1 logisch geheel van veranderingen vormt.

  Om alle veranderingen te committen gebruik je 'darcs record -a'. Aan de
  optie '-m' kan de patchnaam meegegeven worden::

    $ darcs record -am 'srv01 is primary mx'
    Recording changes in "mailname" "postfix/main.cf":

    Finished recording patch 'srv01 is primary mx'

  Dit commando commit alle wijzigingen in de volledige repository. Alleen de
  wijzigingen in bepaalde bestanden of directories committen kan ook::

    $ darcs record -am 'srv01 is primary mx' postfix/main.cf mailname

  Het toevoegen van nieuwe bestanden aan de repository gaat met 'add' ::

    $ darcs add postfix/virtual
    $ darcs record -am 'Gehoste domeinen meenemen' postfix/virtual

  Darcs kan zelf een overzicht van de veranderingen genereren::
 
    $ darcs changes
    Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * Gehoste domeinen meenemen

    Thu Jan 27 17:05:22 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * srv01 is primary mx
  
  Of de uitgebreide versie, van de laatste twee veranderingen::

    $ darcs changes -s --last=2
    Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * Gehoste domeinen meenemen

        A ./postfix/virtual

    Thu Jan 27 17:05:22 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * srv01 is primary mx

        M ./mailname -1 +1
        M ./postfix/main.cf -1 +1

  Een commit kan weer ongedaan gemaakt worden met 'unrecord' ::

    $ darcs unrecord

    Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * Gehoste domeinen meenemen
    Shall I unrecord this patch? [yNvq?] y
    Finished unrecording.

  Meer informatie over de darcs commando's is te vinden in de ingebouwde
  help-functie, op te vragen met 'darcs help' en de Darcs
  "handleiding":http://darcs.net/manual/.
  
Best practices

  Zorg voor een complete historie
   
    Het is goed om ervoor te zorgen dat je een volledige geschiedenis van
    alle veranderingen van een bestand hebt. Dat begint al bij de
    installatie van een nieuwe package. De eerste stap na het installeren
    van een package is om (nog voordat je begint met het aanpassen van
    de configuratiebestanden!) alle nieuwe bestanden en veranderingen die
    van de 'apt-get install' komen te committen. Het "nog voor het
    aanpassen van de configuratiebestanden" deel is hierbij belangrijk.
        
    Door te committen voordat je iets begint aan te passen aan de
    configuratie, kan achteraf precies nagegaan worden welke wijzigingen
    er zijn gedaan op de standaard configuratie die bij de package zit.
    Dat heeft verschillende voordelen:
        
    * Als dezelfde package later nog een keer geinstalleerd moet worden
      op een andere server, kan aan de hand van de historie precies nagegaan
      worden welke wijzigingen nodig zijn na installatie.

    * Wanneer er een bug report gedaan wordt voor een bepaalde Debian
      package, kan makkelijk een overzicht gegenereerd worden van de
      wijzigingen die zijn gedaan aan de configuratiebestanden van die
      package. Dat kan voor de maintainer van de package erg nuttig zijn bij
      het debuggen van problemen.
  
  Gebruik duidelijke omschrijvingen
  
    Een goeie omschrijving is een omschrijving die niet alleen duidelijk is
    voor jezelf, maar vooral ook voor anderen die je omschrijving moeten
    lezen. Maak de beschrijving niet te gedetailleerd, maar probeer de reden
    van de wijziging te beschrijven. Dus niet: "vervang allow-hotplug door
    auto voor eth0", maar: "zorg ervoor dat eth0 altijd automatisch netjes up
    komt". Iemand die wil weten wat er precies veranderd is kan altijd nog de
    precieze verandering bekijken met 'darcs diff' - het heeft geen zin om dat
    nog eens te herhalen in de omschrijving van de patch.
    
    Onthoud ook dat niet alleen wijzelf de omschrijvingen lezen, maar ook
    onze klanten: mensen die misschien niet direct met de wijziging te maken
    hebben en niet van elk onderdeel weten wat het doet. Een wijziging zoals:
    "Verplaats foo.nl van customer-dev naar de customer-live Zope instance" is voor
    iemand die niet weet wat Zope doet of wat de customer-live instance is
    minder duidelijk dan simpelweg "Breng de nieuwe site www.foo.nl
    live".
    
    Gebruik de tegenwoordige tijd voor omschrijvingen, niet de voltooid verleden
    tijd. Dus: "Enable SMTP authentication." en niet "Enabled SMTP
    authentication." Dat lijkt tegennatuurlijk; je beschrijft toch immers wat
    je net hebt gedaan? Maar als je de wijziging bekijkt als een losstaande
    patch die een bepaalde actie uitvoert, dan is het gebruik van de
    tegenwoordige tijd logischer. Je beschrijving hoort bij een patch die een
    bepaalde actie uitvoert en je omschrijving beschrijft wat die actie is.
    Als je dezelfde patch ergens anders zou toepassen, dan vertelt de
    omschrijving wat de patch doet: enable SMTP authentication.
    
  Commit niet te veel, en niet te weinig
        
    Een aanpassing kan vaak wijzigingen aan meerdere bestanden beslaan, die
    niet allemaal bij dezelfde package hoeven te horen. Het is belangrijk om
    al deze wijzigingen als 1 geheel te committen als ze logisch gezien bij
    dezelfde actie horen. Een voorbeeld is het aanzetten van SASL
    authentication voor een mail server zoals Postfix. Daarbij kunnen er
    meerdere bestanden uit verschillende packages aangepast worden: de Postfix
    configuratiebestanden /etc/postfix/main.cf en
    /etc/postfix/sasl/smtpd.conf, en de saslauthd configuratiebestanden
    /etc/saslauthd.conf en /etc/default/saslauthd. Het aanzetten van SASL
    authentication is 1 actie, en de wijzigingen aan al deze bestanden horen
    dan ook bij elkaar in 1 commit.

    Commit dus alle veranderingen die logischerwijs bij elkaar horen als 1 record,
    zodat je precies kunt nagaan welke aanpassingen er allemaal nodig zijn
    voor bijvoorbeeld het aanzetten van bridging in plaats van routing voor
    Xen. De eerstvolgende keer dat je Xen bridging in plaats van routing moet
    aanzetten op een andere server kun je makkelijk nagaan welke bestanden en
    regels er allemaal gewijzigd moeten worden met 'darcs changes' en 'darcs
    diff' op de server waar je die wijziging al een keer hebt gedaan. Iemand
    anders die wil weten wat er allemaal is veranderd voor het aanzetten van
    SASL voor SMTP heeft ook meteen een volledig overzicht van alle
    wijzigingen.
    
    Zorg er ook voor dat je bij het installeren van een package niet alleen
    alle nieuwe configuratiebestanden commit, maar ook wijzigingen aan
    bestaande bestanden. Het installeren van de package dovecot-imapd
    bijvoorbeeld maakt niet alleen nieuwe bestanden aan in /etc/dovecot, maar
    verandert ook /etc/group en /etc/passwd omdat er een nieuwe user genaamd
    dovecot wordt aangemaakt. De veranderingen aan /etc/group en /etc/passwd
    commit je dan ook tegelijkertijd met het toevoegen van de nieuwe
    bestanden.
    
    Ook belangrijk is dat je geen wijzigingen meeneemt met je commit die niet
    bij je verandering horen. Dat kan gebeuren als er een wijziging aan een
    bestand is geweest die nog niet gecommit is, bijvoorbeeld omdat het nog
    niet af is. Je kunt met 'darcs whatsnew' controleren of je commit volledig
    is, en of je geen wijzigingen meeneemt die niet bij je aanpassing horen.
    Controleer na het committen ook nog een keer met 'darcs changes -s' of je
    niet teveel bestanden hebt meegenomen in je commit. Zie de voorbeelden
    onder "Darcs in de praktijk" voor wat meer uitleg over het gebruik van de
    commando's.
      
Darcs in de praktijk
    
  Installatie nieuwe package

    Je installeert de IMAP server van Dovecot::
    
      $ sudo apt-get install dovecot-imapd

    Kijk welke bestanden zijn toegevoegd::
    
      $ cd /etc
      $ darcs whatsnew -sl
      M ./group -1 +2
      M ./passwd +1
      a ./dovecot/
      a ./dovecot/dovecot-ldap.conf
      a ./dovecot/dovecot-sql.conf
      a ./dovecot/dovecot.conf
      a ./init.d/dovecot
      a ./pam.d/dovecot

    Controleer of de wijzigingen in group en passwd inderdaad van de
    installatie van Dovecot komen::
    
      $ darcs whatsnew passwd group
      What's new in "group" "passwd":

      {
      hunk ./group 9
      -mail:x:8:
      +mail:x:8:dovecot
      hunk ./group 53
      +dovecot:x:112:
      hunk ./passwd 30
      +dovecot:x:109:112:Dovecot mail server,,,:/usr/lib/dovecot:/bin/false
      }
    
    Voeg vervolgens alle nieuwe bestanden toe, en commit deze samen met de
    wijzigingen in bestaande bestanden::
    
      $ darcs add -r dovecot pam.d/dovecot init.d/dovecot
      $ darcs record -am 'apt-get install dovecot' dovecot init.d/dovecot pam.d/dovecot group passwd
      Recording changes in "dovecot" "group" "init.d/dovecot" "pam.d/dovecot" "passwd":

      Finished recording patch 'apt-get install dovecot'
      
    Het meegeven van de bestanden aan 'darcs record' zorgt ervoor dat je niet
    zomaar alles in /etc commit. Als je zeker wilt weten dat je niet teveel
    bestanden met je commit hebt meegenomen kun je je commit controleren met::
    
      $ darcs changes -s | less
      
    Als de commit niet klopt, kun je die ongedaan maken met::
    
      $ darcs unrecord
      
      Fri Aug 24 16:47:31 CEST 2007  Bart Cortooms <bart@hiccup.nl>
        * apt-get install dovecot
      Shall I unrecord this patch? (1/2)  [ynWvpxqadjk], or ? for help: y
      
      Fri Aug 24 16:43:17 CEST 2007  Bart Cortooms <bart@hiccup.nl>
        * Initial commit
      Shall I unrecord this patch? (2/2)  [ynWvpxqadjk], or ? for help: d
      Finished unrecording.
      
    De 'd' als antwoord op de laatste vraag betekent "done": voor de commit
    waarop 'done' is geantwoord wordt geen unrecord gedaan.
  
  Een gedeelte van de wijzigingen committen
  
    Soms staan er ongecommitte wijzigingen open, die je niet mee wilt nemen
    bij je commit, omdat ze niet bij je aanpassing horen. Als de ongecommitte
    wijzigingen andere bestanden beslaan dan jouw aanpassing, dan kun je bij
    de record simpelweg alleen de bestanden meegeven die je wilt committen.
    
    Maar soms komt het ook voor dat een bepaald bestand 2 wijzigingen bevat
    die eigenlijk twee verschillende aanpassingen zijn. In zo'n geval kun je
    ook maar een gedeelte van de wijzigingen in een bestand committen, door
    bij de darcs record geen '-a' mee te geven.
    
    We zetten imap en imaps aan voor dovecot en controleren daarna de
    ongecommitte wijzigingen::
    
      $ sudo vi dovecot/dovecot.conf
      $ darcs whatsnew -s
      M ./dovecot/dovecot.conf -10 +10
    
    Zoveel regels hebben we niet aangepast, dus we controleren wat er precies veranderd is::
    
      $ darcs whatsnew dovecot
      What's new in "dovecot":

      {
      hunk ./dovecot/dovecot.conf 20
      -#protocols = imap imaps
      -protocols =
      +protocols = imap imaps
      +#protocols =
      hunk ./dovecot/dovecot.conf 972
      -  # socket listen {
      -  #   master {
      -  #     path = /var/run/dovecot/auth-master
      -  #     mode = 0600
      -  #     user = mail # User running Dovecot LDA
      -  #     #group = mail # Or alternatively mode 0660 + LDA user in this group
      -  #   }
      -  # }
      +  socket listen {
      +    master {
      +      path = /var/run/dovecot/auth-master
      +      mode = 0600
      +      user = mail # User running Dovecot LDA
      +      #group = mail # Or alternatively mode 0660 + LDA user in this group
      +    }
      +  }
      }

    Blijkbaar is er nog iemand bezig met het configureren van de LDA. Die
    wijziging willen we niet meenemen met de commit, dus we gebruiken geen -a
    bij de 'darcs record' en selecteren alleen onze eigen wijziging door 'y'
    te antwoorden op de eerste vraag, en 'n' op de tweede vraag::
   
      $ darcs record -m dovecot/dovecot.conf
      Recording changes in "dovecot/dovecot.conf":

      hunk ./dovecot/dovecot.conf 20
      -#protocols = imap imaps
      -protocols =
      +protocols = imap imaps
      +#protocols =
      Shall I record this change? (1/?)  [ynWsfqadjkc], or ? for help: y
      hunk ./dovecot/dovecot.conf 972
      -  # socket listen {
      -  #   master {
      -  #     path = /var/run/dovecot/auth-master
      -  #     mode = 0600
      -  #     user = mail # User running Dovecot LDA
      -  #     #group = mail # Or alternatively mode 0660 + LDA user in this group
      -  #   }
      -  # }
      +  socket listen {
      +    master {
      +      path = /var/run/dovecot/auth-master
      +      mode = 0600
      +      user = mail # User running Dovecot LDA
      +      #group = mail # Or alternatively mode 0660 + LDA user in this group
      +    }
      +  }
      Shall I record this change? (2/?)  [ynWsfqadjkc], or ? for help: n
      What is the patch name? Zet IMAP en IMAPS aan
      Do you want to add a long comment? [yn]n
      Finished recording patch 'Zet IMAP en IMAPS aan'
      
  Een wijziging ongedaan maken

    Soms wil je terug naar de versie van een bestand zoals die was bij de
    laatste commit. Dat kan met het commando 'revert'::

      $ sudo darcs revert dovecot/dovecot.conf
      Reverting changes in "dovecot/dovecot.conf"..

      hunk ./dovecot/dovecot.conf 20
      -#protocols = imap imaps
      -protocols =
      +protocols = imap imaps
      +#protocols =
      Shall I revert this change? (1/?)  [ynWsfqadjkc], or ? for help: n
      hunk ./dovecot/dovecot.conf 972
      -  # socket listen {
      -  #   master {
      -  #     path = /var/run/dovecot/auth-master
      -  #     mode = 0600
      -  #     user = mail # User running Dovecot LDA
      -  #     #group = mail # Or alternatively mode 0660 + LDA user in this group
      -  #   }
      -  # }
      +  socket listen {
      +    master {
      +      path = /var/run/dovecot/auth-master
      +      mode = 0600
      +      user = mail # User running Dovecot LDA
      +      #group = mail # Or alternatively mode 0660 + LDA user in this group
      +    }
      +  }
      Shall I revert this change? (2/?)  [ynWsfqadjkc], or ? for help: y
      Do you really want to revert these changes? y
      Finished reverting.

    Het is hier uiteraard belangrijk om het bestand mee te geven dat je
    wilt reverten, om te voorkomen dat je *alle* wijzigingen ongedaan
    maakt!
    
    Voor het uitvoeren van een revert heb je meestal root rechten nodig,
    omdat de eigenaar van de bestanden in /etc gewoonlijk root is, en niet
    je eigen user. Gebruik dan ook 'sudo darcs revert' om voor dat
    commando tijdelijk root te worden.
      
  Een bestand verplaatsen
  
    Als je een bestand wilt verplaatsen, dan zou je natuurlijk gewoon met 'mv'
    het bestand kunnen verplaatsen, de nieuwe locatie van het bestand opnieuw
    toevoegen met 'darcs add', de oude locatie van het bestand verwijderen uit
    de repository en vervolgens alles committen.
    
    Maar dat heeft 1 belangrijk nadeel: de historie van het verplaatste
    bestand wordt niet bewaard. Vandaar dat darcs een eigen 'mv' commando
    heeft, dat ervoor zorgt dat de historie bewaard wordt. Het gebruik is
    precies zoals je het Unix commando 'mv' zou gebruiken::
    
      $ sudo darcs mv aliases mail/aliases

    Darcs houdt bij dat het bestand verplaatst is, en verplaatst ook meteen
    het fysieke bestand van de oude naar de nieuwe locatie. Dat laatste is ook
    de reden dat we hier 'sudo' moeten gebruiken.
    
    De verplaatsing is nu nog niet gecommit in de repository. De output van
    whatsnew ziet er als volgt uit::
    
      $ darcs whatsnew -s
     ./aliases -> ./mail/aliases
     
    Vervolgens kunnen we onze wijziging committen in de repository::
    
      $ darcs record -am 'Postfix 3.0 wil haar aliases bestand standaard in /etc/mail/aliases hebben staan.' aliases
      Recording changes in "aliases":

      Finished recording patch 'Postfix 3.0 wil haar aliases bestand standaard in /etc/mail/aliases hebben staan.'
      
    En de geschiedenis van het bestand is ook op de nieuwe locatie nog steeds
    te bekijken::
    
      $ darcs changes -s mail/aliases
      Changes to mail/aliases:
      
      Sun Aug 20 19:31:54 CEST 2006  Bart Cortooms <bart@hiccup.nl>
        * Gebruik nu standaard foo.nl in plaats van bar.com. (Beide domeinen blijven werken voor zowel mail als de web
      pagina's.)
    
  Nagaan wat er is veranderd bij een bepaalde commit
  
    Als we willen nagaan wat er precies is veranderd bij een bepaalde commit,
    dan kunnen we daarvoor 'darcs diff' gebruiken. Om de diff op te kunnen
    vragen hebben we eerst de naam van de patch nodig::
    
      $ darcs changes -s | less

      Sun Jul 15 11:51:18 CEST 2007  Bart Cortooms <bart@hiccup.nl>
        * Move the Xen network setup from routing to bridging.

          M ./ferm/ferm.conf -1 +1
          R ./network/if-up.d/002xen
          M ./network/interfaces -10 +16
          M ./xen/domains/always/backup.cfg -1 +1
          M ./xen/domains/always/hosting.cfg -1 +1
          M ./xen/domains/always/stepstone.cfg -1 +1
          M ./xen/domains/always/zope.cfg -1 +1
          M ./xen/domains/sometimes/builder.cfg -1 +1
          M ./xen/xend-config.sxp -3 +3

    De naam van een patch is de eerste regel in een omschrijving. Om een
    bepaalde patch te specificeren hoeven we niet per se de volledige naam mee
    te geven: een gedeelte van de patchnaam is voldoende, zolang het maar
    uniek herkenbaar is voor Darcs.
    
     Het opvragen van de precieze veranderingen gaat met 'darcs diff' (gebruik
    -u voor unified formaat, en --patch voor het kiezen van de patch)::

      $ darcs diff -u --patch='routing to bridging' | less
      Sun Jul 15 11:51:18 CEST 2007  Bart Cortooms <bart@hiccup.nl>
        * Move the Xen network setup from routing to bridging.
      diff -rN -u old-etc/ferm/ferm.conf new-etc/ferm/ferm.conf
      --- old-etc/ferm/ferm.conf      2007-08-24 15:36:14.000000000 +0200
      +++ new-etc/ferm/ferm.conf      2007-08-24 15:36:14.000000000 +0200
      @@ -4,7 +4,7 @@
       #  Configuration file for ferm(1).
       #

      -def $IF_EXT = eth2;
      +def $IF_EXT = xenbr1;
       def $IP_EXT = 62.133.200.14;
       def $NET_INT = 172.21.0.0/16;

      diff -rN -u old-etc/network/if-up.d/002xen new-etc/network/if-up.d/002xen
      --- old-etc/network/if-up.d/002xen      2007-08-24 15:36:14.000000000 +0200
      +++ new-etc/network/if-up.d/002xen      1970-01-01 01:00:00.000000000 +0100
      @@ -1,8 +0,0 @@
      -#!/bin/sh -e
      -#
      -# Voor Xen networking
      -#
      -for interface in eth2 eth3; do
      -    test -f    /proc/sys/net/ipv4/conf/$interface/proxy_arp && \
      -      echo 1 > /proc/sys/net/ipv4/conf/$interface/proxy_arp
      -done
      diff -rN -u old-etc/network/interfaces new-etc/network/interfaces
      --- old-etc/network/interfaces  2007-08-24 15:36:14.000000000 +0200
      +++ new-etc/network/interfaces  2007-08-24 15:36:14.000000000 +0200
      @@ -5,24 +5,30 @@
       auto lo
       iface lo inet loopback
      [...]
