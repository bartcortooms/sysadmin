Sudo

	Man pages: sudo(8), sudoers(5), visudo(8).

	Sudo is een programma waarmee commando's als een andere gebruiker
	uitgevoerd kunnen worden. Zoiets als 'su $user -c commando' dus, maar
	dan veel uitgebreider.

	De instellingen van sudo worden opgeslagen in /etc/sudoers, en kunnen
	worden aangepast met het commando visudo.

	Als sudo nog niet eerder is gebruikt moet er een wachtwoord worden
	opgegeven. Elke keer dat sudo gebruikt wordt, wordt er voor de
	gebruiker een timestamp bijgewerkt. Vanaf die timestamp mag voor een
	bepaalde tijd (standaard een paar minuten) sudo gebruikt worden zonder
	dat er een wachtwoord opgegeven hoeft te worden.

De belangrijkste sudo functies

	sudo commando     --  Voert commando uit als een bepaalde user -
			      afhankelijk van de instellingen in /etc/sudoers
			      wordt er gekeken of de gebruiker dit commando uit
			      mag voeren en als welke user het programma wordt
			      gestart.

	sudo -l           --  Laat alle commando's zien die de gebruiker met
			      sudo mag starten. Dit update ook de timestamp van
			      een gebruiker.

	sudo -k           --  Zet de timestamp op 00:00:00 1970-01-01 (UNIX
			      epoch), zodat er bij de volgende sudo weer een
			      wachtwoord opgegeven moet worden.

Voordelen

	- Logging.  Elk via sudo uitgevoerde commando wordt via syslogd gelogd.

	- Niet meer per ongeluk een root prompt open laten staan (niet voor lang
	  in ieder geval).

	- Mogelijkheid om het gebruik van sudo te beperken tot 1 commando.
	  Bijvoorbeeld 'adduser' voor voor iedereen in group staff, of
	  '/etc/init.d/apache restart' voor de webmaster.


Nadelen

	- Er moet vaker een wachtwoord ingetypt worden.

	- Voor elk commmando moet sudo gezet worden.

	- Pipes en redirects zijn soms lastig.  Om een redirect als root uit te
	  voeren moet er zoiets als dit gebruikt worden: 'sudo sh -c "ls > bla"'.

	- Een extra setuid binary: /usr/bin/sudo.

	- Werken in een directory waartoe de gebruiker die sudo aanroept geen
          toegang heeft werkt niet prettig.
