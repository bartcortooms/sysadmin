Man pages: sudo(8), sudoers(5), visudo(8).

Sudo is a program to run commands as a different user, normally root. It is much like 'su $user -c command', just more advanced.

Sudo stores its settings in /etc/sudoers, which can be modified with the commando visudo.

If sudo hasn't been used recently, it will ask you for your password the first time you run it. Every time sudo is used, a timestamp will be updated. From that moment on sudo can be used for a few minutes without having to enter a password. If the timestamp expires, you will need to enter your password again when running sudo.

The main sudo commands

 - **sudo command** -- Executes 'command' as a certain user. The settings in /etc/sudoers determine if the user may execute this command and which user the command should run as.

 * **sudo -l** -- Shows all commands you can run with sudo. This will also update your timestamp.

 * **sudo -k** -- Sets the timestamp to 00:00:00 1970-01-01 (UNIX epoch), resulting in a password prompt the next time you run sudo.

Advantages of using sudo

 - It makes it easier to switch to root for a very short time.  This makes it more likely and convenient to get into the habit of only being root when you really need to be root.
          
 - Logging.  Every command will be logged with sudo, so you can look up which commands have been run with sudo before.  Which can be a big help when you're not the only on maintaining the system.

 - No more root shells which get left behind (not for long, anyway).

Disadvantages of using sudo

 - If you're used to having a root shell open (don't, it's is a bad habit), you'll need to type a password more often.
 
 - You'll need prepend every commando which should run as root with 'sudo'.

 - Pipes and redirects can be difficult.  To do a redirect as root, you'll need to use something like this: 'sudo sh -c "ls > test"'.

 - If you're in a directory for which you don't have read permissions as a normal user, sudo is a pain. This is one of the very few cases where you should just do a 'sudo -s' to get a root shell.
