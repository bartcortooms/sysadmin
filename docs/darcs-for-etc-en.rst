"Darcs":http://www.darcs.net/  is an advanced versioning system. Although
advanced, it's also pretty easy to use. If used for only the most basic
versioning tasks, it's pretty much like any other versioning control software
(CVS, Subversion, Arch and others). But it does have its own peculiarities. One
of them is that the Darcs repository is in the same directory as the working
directory; the working directory ''is'' the repository, sort of. All files
Darcs needs for versioning are in the directory _darcs. There is only one
_darcs directory; in the case of /etc, which this document is about, it's
/etc/_darcs. This differs from CVS and Subversion, where every subdirectory
contains a CVS or .svn directory.

When a file in /etc has been changed, this change can be commited with the
darcs command 'record'. A commit, or record, can cover changes in multiple
files, making it possible to group changes which logically belong together in
one big commit.

There are other commands, like 'whatsnew', which show the changes which have
not yet been recorded. For example, if you've changed some configuration files
and you want to record these changes in the repository, first use the darcs
command 'whatsnew' to see which changes have not yet been recorded::

  $ sudo vi mailname
  $ sudo vi postfix/main.cf
  $ darcs whatsnew -s
  M ./mailname -1 +1
  M ./postfix/main.cf -1 +1
  $ darcs whatsnew
  {
  hunk ./mailname 1
  -srv01.example.nl
  +example.nl
  hunk ./postfix/main.cf 12
  -myhostname = srv01.example.nl
  +myhostname = mail.example.nl
  }

The option '-l' shows which files ''are'' in the directory, but have not yet
been added to the repository::

  $ darcs whatsnew -sl
  a ./postfix/virtual

You can save changes in the repository (record) with your own user account. No
root privileges are needed. Darcs does need an email address to mark your
records with, which can be set in ~/.darcs/author. For example::

  $ cat ~/.darcs/author
  Bart Cortooms <bart@hiccup.nl>

Now save the changes in the repository::

  $ darcs record
  hunk ./mailname 1
  -srv01.example.nl
  +example.nl
  Shall I record this patch? (1/2)[ynWsfqadjk], or ? for help: y
  hunk ./postfix/main.cf 12
  -myhostname = srv01.example.nl
  +myhostname = mail.example.nl
  Shall I record this patch? (2/2) [ynWsfqadjk], or ? for help: y
  What is the patch name? srv01 is primary mx
  Do you want to add a long comment? [yn] n
  Finished recording patch 'srv01 is primary mx'

For every change, Darcs will ask you if it belongs with this record. This
allows you to skip some changes which do not really belong with this record,
and record these later with a seperate record.

If you're sure all changes made to a file logically belong together, you can
record all changes at once with 'darcs record -a'. The '-m' option can be used
to pass the commit message on the command line::

  $ darcs record -am 'srv01 is primary mx'
  Recording changes in "mailname" "postfix/main.cf":

  Finished recording patch 'srv01 is primary mx'

This command will commit all changes in the entire directory. Only commiting
the changes in some files or directories is also possible::

  $ darcs record -am 'srv01 is primary mx' postfix/main.cf mailname

Adding new files to the repository is done with the command 'add'::

  $ darcs add postfix/virtual
  $ darcs record -am 'Include hosted domains' postfix/virtual

Darcs can also generate a changelog::

  $ darcs changes
  Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
    * Include hosted domains

  Thu Jan 27 17:05:22 CET 2005  Bart Cortooms <bart@hiccup.nl>
    * srv01 is primary mx
  
A changelog of the latest two changes (--last=2) and the files which were modified (-s)::

  $ darcs changes -s --last=2
  Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
      * Include hosted domains

      A ./postfix/virtual

  Thu Jan 27 17:05:22 CET 2005  Bart Cortooms <bart@hiccup.nl>
    * srv01 is primary mx

      M ./mailname -1 +1
      M ./postfix/main.cf -1 +1

A commit can be undone with 'unrecord'::

  $ darcs unrecord

  Thu Jan 27 17:05:51 CET 2005  Bart Cortooms <bart@hiccup.nl>
    * Include hosted domains
  Shall I unrecord this patch? [yNvq?] y
  Finished unrecording.

More about Darcs can be found in the built-in help function, accessible with
'darcs help' and in the "Darcs manual":http://darcs.net/manual.
