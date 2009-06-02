Aanmaken van een Darcs repository voor /etc

  Darcs zet alle bestanden voor de repository in '_darcs/' in de working
  directory. Alle bestanden zijn plaintext, dus aan te passen met een standaard
  texteditor. Het aanmaken van de darcs repository in /etc gaat met::

    $ sudo darcs init
    $ sudo chown -R root:root _darcs
    $ sudo chmod -R g+w,o-rx _darcs

  De chown en chmod zorgen ervoor dat iedereen in de groep 'root' rechten
  heeft om een commit te doen zonder root te hoeven zijn.

  Niet alle bestanden hoeven in de repository te komen staan. Het bestand
  '_darcs/prefs/boring' bevat regular expressions voor bestanden die door darcs
  genegeerd moeten worden. Aan de standaard lijst kunnen de volgende regexes
  worden toegevoegd::

    \.db$
    \.dpkg-(old|new|tmp|dist)$
    \.old$
    \.pem$
    \.ucf-old$
    ^\.pwd\.lock$
    ^adjtime$
    ^apt/secring\.gpg$
    ^apt/trustdb\.gpg$
    ^apt/trusted\.gpg$
    ^bind/rndc.key$
    ^blkid\.tab$
    ^cacti/debian\.php$
    ^dancer-ircd/olines$
    ^exim4/passwd\.client$
    ^g?shadow-?$
    ^group-$
    ^l2tpd/l2tp-secrets$
    ^ld\.so\.cache$
    ^lilo\.conf\.shs$
    ^locale\.gen$
    ^localtime$
    ^lvm/archive
    ^lvm/backup
    ^lvm/\.cache
    ^motd$
    ^mtab$
    ^mysql/debian\.cnf$
    ^nagios/htpasswd\.users$
    ^nagios/ssh
    ^network/run/ifstate$
    ^passwd-$
    ^phpmyadmin/blowfish_secret.inc.php$
    ^postgresql/pg_hba\.conf$
    ^postgresql/pg_ident\.conf$
    ^ppp/chap-secrets$
    ^ppp/pap-secrets$
    ^racoon/psk\.txt$
    ^radiusclient/servers$
    ^sasldb2$
    ^ssh/ssh_host_[dr]sa_key$
    ^ssl/private
    ^ssl/index.txt(.attr)?$
    ^ssl/newcerts
    ^ssl/requests
    ^ssl/revoked\.crl$
    ^ssl/serial$
    ^sudoers$

  Het toevoegen van bestanden en directories aan de respository kan met 'darcs
  add'. Voeg alle bestanden die niet in 'boring' staan als volgt toe::

    $ darcs whatsnew -sl | while read status file; do darcs add "$file"; done

  Committen van de adds gaat vervolgens met::

    $ darcs record -am 'initial checkin'
