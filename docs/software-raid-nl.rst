RAID configuratie

  De schijven in de array hebben elk 1 grote partitie, partitie type id
  "FD" (Linux raid autodetect). De RAID array /dev/md0 bestaat bijvoorbeeld
  uit de partities /dev/hda1 en /dev/hdc1. Er hoeven niet per se partities
  aangemaakt te worden op de schijven die in de RAID array zitten, maar
  dit is de manier waarop de Debian installer de RAID heeft aangemaakt.

Verwijderen defecte schijf

  Wanneer een disk vervangen moet worden, moet eerst de defecte schijf
  uit de array gehaald worden::

    $ mdadm --set-faulty /dev/md0 /dev/hdc1
    $ mdadm --remove /dev/md0 /dev/hdc1

  **Let op**: Er staat maar op 1 van de schijven in de RAID array een
  bootable MBR, namelijk /dev/hda. Als /dev/hda stuk gaat, kan er niet
  meer vanaf de harde schijf geboot worden en zal dus van iets anders
  geboot moeten worden (bijvoorbeeld het netwerk, of een CD-ROM).

Plaatsen nieuwe schijf

  Na het verwijderen van de defecte schijf uit de array kan de schijf
  vervangen worden en de nieuwe disk aan de raid array toegevoegd worden.
  Maak daarvoor eerst met fdisk een nieuwe partitie aan op de nieuwe
  schijf, met partitie id "FD".

  Vervolgens moet voor de zekerheid de superblock op de nieuwe schijf nog
  leeggemaakt worden::

    $ mdadm --zero-superblock /dev/hdc1

  De nieuwe schijf kan nu aan de RAID array toegevoegd worden::

    $ mdadm /dev/md0 -a /dev/hdc1

  Het RAID array zal nu opnieuw gebouwd worden: de data van de
  niet-vervangen schijf wordt gekopieerd naar de schijf die vervangen is.
  Afhankelijk van de snelheid kan dat makkelijk een uur duren, maar de
  RAID array is ook tijdens het herbouwen te gebruiken. In /proc/mdstat is
  de voortgang van het herbouwen van de array te volgen.
