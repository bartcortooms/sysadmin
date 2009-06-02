Lokale backups met rsnapshot

  "rsnapshot":http://www.rsnapshot.org/ maakt gebruik van rsync om
  snapshots (backups) van bepaalde directories te maken. Je kunt
  meerdere intervallen opgeven waarop rsnapshot een snapshot moet maken, en
  hoeveel snapshots er van zo'n interval bewaard moeten worden. Een interval
  is bijvoorbeeld elke 4 uur. Door 6 van die 4-uurlijkse snapshots te
  bewaren heb je recente backups van de afgelopen 24 uur. Daarnaast kun je
  nog dagelijkse snapshots, wekelijkse snapshots en maandelijkse snapshots
  maken, om nog verder terug te kunnen gaan in de tijd.

  De directories waar de snapshots in komen te staan ziet er als volgt uit::

    bart@server01:/backup/rsnapshot$ ls -x
    daily.0   daily.1   daily.2   daily.3
    daily.4   daily.5   daily.6   hourly.0
    hourly.1  hourly.2  hourly.3  hourly.4
    hourly.5

  hourly.0 is de laatst aangemaakte snapshot, maximaal 4 uur oud.  hourly.1 is
  de snapshot van 4 uur daarvoor, enzovoort. daily.0 is de laatst aangemaakte
  dagelijkse backup, maximaal 1 dag oud. Na een tijdje komen er ook directories
  bij voor weekly en monthly.

  rsnapshot slaat bij het maken van een backup een bestand dat niet is
  veranderd sinds een vorige snapshot niet dubbel op, maar maakt in dat geval
  een hardlink aan naar het bestand in de vorige snapshot. Zo wordt ruimte
  bespaard, omdat lang niet alle bestanden elke 4 uur wijzigen. Is er wel een
  verandering in het bestand, dan wordt het volledige bestand opnieuw
  opgeslagen in de nieuwe snapshot.

Off site backups met rdiff-backup

  Het maken van off site backups kan met zowel rsnapshot als met
  "rdiff-backup":http://www.nongnu.org/rdiff-backup. Een verschil
  tussen de twee is dat rsnapshot gestart wordt vanaf de backupserver
  en dus als root moet inloggen op de machine die gebackupt moet worden.
  
  rdiff-backup wordt gestart op de machine waarvan de backup gemaakt
  moet worden en draait op alleen die machine als root gedurende het
  maken van de backup. Het inloggen op de backupserver (door middel
  van ssh) kan als normale gebruiker.

  rdiff-backup is gebaseerd op het rsync-algoritme maar gebruikt in
  tegenstelling tot rsnapshot daar de rdiff library voor en niet
  rechtstreeks rsync. Net als rsnapshot verstuurt rdiff-backup alleen
  het verschil tussen twee bestanden. Alle deltas (diffs) tussen de
  bestanden worden bewaard, zodat er ook teruggegaan kan worden naar een
  eerdere versie van een bestand.

  De directory waarin rdiff-backup de backups zet, ziet er bijvoorbeeld als
  volgt uit::

    bart@backupserver:/backup/rdiff-backup/server01$ ls
    etc  home  rdiff-backup-data  usr  var

  Bij een wijziging van een bestand wordt alleen de delta (de diff) opgeslagen,
  in de rdiff-backup-data directory. rdiff-backup gebruikt daardoor minder
  ruimte dan rsnapshot voor het opslaan van de backups.  In de directories die
  gebackupt zijn, hier 'etc', 'home', 'usr' en 'var' is altijd de laatste
  backup van een bestand te vinden.

  Het terugzetten van een vorige versie van een bestand kan alleen door het
  rdiff-backup commando te gebruiken, omdat van vorige versies alleen de diffs
  bewaard worden, niet het volledige bestand zoals bij rsnapshot.

  rdiff-backup wordt normaal gesproken gestart vanuit een cronjob, als user
  root.  Vanaf de server die gebackupt wordt, logt rdiff-backup via ssh in
  als op de backupserver om daar de backup op te slaan.

  Voor de SSH-sessie kun je een keypaar om in te loggen, zodat er geen
  wachtwoord ingegeven hoeft te worden door rdiff-backup. In dit geval logt
  rdiff-backup in als de gebruiker 'backup' en staat in
  /backup/.ssh/authorized_keys de public key van root@server01, waarmee
  alleen rdiff-backup in server-mode kan worden aangeroepen, geen tty mag
  worden gebruikt, etc.

  /backup/.ssh/authorized_keys ziet er als volgt uit::

    command="rdiff-backup --server --restrict /backup/rdiff-backup/server01",
    from="server01",no-pty,no-port-forwarding,no-agent-forwarding,
    no-X11-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAA...

  (Note: Dit is eigenlijk 1 lange regel, maar voor de leesbaarheid is
  het verdeeld over meerdere regels.)

  Om ervoor te zorgen dat sshd op de backupserver in /backup/.ssh kijkt voor
  de authorized_keys file, is /backup ingesteld als de homedirectory van de
  user backup. De group en owner van /backup/rdiff-backup/server01 zijn
  ingesteld op backup:backup, zodat de user backup in die directory kan
  komen en de bestanden erin weg kan schrijven.
