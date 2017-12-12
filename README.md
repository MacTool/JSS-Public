# JSS-Public

# MakeMeAdmin.sh 

Intended for use as a JSS self service item.  Grants admin rights to the logged in user (via Self Service) for 30
minutes and then revokes the rights automatically.  An email is generated with the user reason for needing admin rights along
with the computer name.  In addition, a log file is generated/updated at /usr/local/elect/elect.txt.  It also checks if the user
already has admin rights before granting.

All dialogs are via AppleScript.
