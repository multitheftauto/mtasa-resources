MTA: Ingame Handling Editor
=====

Any trouble with the handling editor? [Be sure to post it here!](http://forum.mtasa.com/viewtopic.php?f=108&t=30494 "Forum topic") Problems with installing? Feel free to ask there too! Found a bug, tell us [here!](https://github.com/hedit/hedit/issues)

Here are some quick links:
* [Instant IRC support - don't ask to ask, just ask!](http://mibbit.com/#mta@irc.gtanet.com)
* [Forum topic](http://forum.mtasa.com/viewtopic.php?f=108&t=30494)
* [Issue/bug tracker](https://github.com/hedit/hedit/issues)
* [Download latest release](https://github.com/hedit/hedit/releases/latest)
* [See list of releases](https://github.com/hedit/hedit/releases)
* [Download latest nightly code *bleeding edge!*](https://github.com/hedit/hedit/archive/master.zip)

Getting started with the Handling Editor
-------
You'll download the latest release from the [releases page](https://github.com/hedit/hedit/releases). It's as simple as pressing "download zip"!

First of all, you need a MTA server.

Once you downloaded the ZIP package, open it. Here you will see a folder called "hedit". Don't change the name from "hedit" to anything else! You have to copy this folder to your Multi Theft Auto SERVER resources folder. This folder is usually located at this path:
C:\Program Files\MTA San Andreas 1.3\server\mods\deathmatch\resources on your computer.
If you're using a 64-bit version of Windows, you have to search your server in "Program Files (x86)" instead.

Now go back to the "deathmatch" folder. Her you will find a file called "acl.xml". Place the following line into the admin group and paste `<object name="resource.hedit"></object>` underneath the line where `resource.admin` is - you'll know where to put it.

Once you placed the folder there, start your server and type "start hedit" into the console. Make sure you have sufficient rights to start a resource! Now you've successfully installed and started the editor!


