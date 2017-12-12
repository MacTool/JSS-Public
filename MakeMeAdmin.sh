#!/bin/sh


#################################
#
# Make Me a Temp Admin
#
# 2017-Frank Wolf 
# 
# updated 2017-12-12
#################################


#################################
#
# Variables
#
#################################


admReason=0 # text for reason
admReqEmail=0# email address for notification
tmpAdmin=$3 # username for admin rights, log files, etc
compName=`scutil --get ComputerName`
# get admin list
allAdmins=$(dscl . -read /Groups/admin GroupMembership | sed 's/^.*: //' )
#echo $allAdmins
# convert to array
userArray=($allAdmins)
# network status



#################################
#
# Functions
#
#################################

# initial prompt for info
start_adm() {
admReason=$(osascript <<- giveReason

	set newAdmin to "$tmpAdmin"

	tell Application "Finder"
	
		activate
		
		set admReason to text returned of (display dialog "Greetings "& newAdmin & "!" & return & return & " Admin rights will be granted for 30 minutes. Please enter the reason for using admin rights below.  Your response will help us better serve your future needs." default answer "" with title "Activating Admin Rights")
		
	end tell
return admReason
EOF)

# create log file
if [ ! -d /usr/local/elect ]; then
mkdir /usr/local/elect
fi


# drop daemon remove admin and start cleanup function
if [ ! -f /Library/LaunchDaemons/com.admin.temp.plist ]; then

cat >> /Library/LaunchDaemons/com.admin.temp.plist <<AGTEMP
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Label</key>
        <string>com.admin.temp</string>
        <key>ProgramArguments</key>
        <array>
        	<string>/usr/local/elect/admCleanup.sh</string>
        </array>
	<key>StartInterval</key>
	<integer>1800</integer> 
</dict>
</plist>
AGTEMP

else

adm_exist

fi

# drop cleanup script
if [ ! -f /usr/local/elect/admCleanup.sh ]; then

cat >> /usr/local/elect/admCleanup.sh <<ADMCLEAN 
#!/bin/sh
adm_clean(){

	rm /Library/LaunchDaemons/com.admin.temp.plist
	rm /usr/local/elect/admCleanup.sh

	}

trap adm_clean EXIT

	/usr/sbin/dseditgroup -o edit -d $tmpAdmin -t user admin
	launchctl unload -w /Library/LaunchDaemons/com.admin.temp.plist
	defaults write /Library/LaunchDaemons/com.admin.temp.plist disabled -bool true

ADMCLEAN

chmod ugo+x /usr/local/elect/admCleanup.sh

else

adm_exist

fi

#send email to record in Footprints

( echo "Subject: Temp Admin rights granted on $compName"; echo; echo "Please assign to Support for record keeping. Temporary Admin rights have been granted via Self Service on $compName to $tmpAdmin for the following reason: $admReason" ) | sendmail -f "$tmpAdmin@purdue.edu" "$admReqEmail"

launchctl load -w /Library/LaunchDaemons/com.admin.temp.plist

/usr/sbin/dseditgroup -o edit -a $tmpAdmin -t user Admin

TIME=`date "+Date:%m-%d-%Y TIME:%H:%M:%S"`
echo $TIME " by " $tmpAdmin " for reason: " $admReason >> /usr/local/elect/elect.txt

echo "Temp admin rights granted to " $tmpAdmin

exit 0
}


# 
adm_exist() {

admQuite=$(osascript <<- chkAdmin

	set newAdmin to "$tmpAdmin"
	
	tell Application "Finder"
	
		activate
		
		display dialog "Greetings "& newAdmin & "!" & return & return & "It appears that you are already a member of the local Administrators group." & return & return & "If you have run this Self Service Policy already, you are still within the 30 minute window." & return & "Otherwise, please contact Desktop Support for assistance." with title "Admin rights exists."
	end tell
EOF)

exit 0
}


#################################
#
# Main Script
#
#################################


## Get username for logged in user and assign to tmpAdmin

# Using built in variable from JSS

echo "Starting Temp Admin granting process for" $tmpAdmin


#check if user is already an Admin
if [[ ${userArray[*]} =~ "$tmpAdmin" ]]; then
	echo "Already an admin"
	isAdmin="Yes"
	adm_exist
	exit 0
else 
	echo "No"
	isAdmin="No"
	start_adm
fi




