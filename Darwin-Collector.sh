#!/bin/bash
###These commands should be run while at the root of the target machine or mounted image. May require Sudo privilege even for mounted devices. If run as Sudo the users cleanup action may not work properly but it will only result in a few additional errors.
###If this script does not execute on a Mac OS, copy and paste into vi and re-save. XCode also works on Mac. The issues is with white spaces.
###Last Updated on 05/29/2018 for MacOS 10.13.4; Darwin Kernel Version 17.5.0. Created by Brock Bell Git @Broctets-and-Bytes
###############################################################################
###Script Starts###
###Ask the user where they want to store the collected data. If including the sleep file this should be a large storage location greater than the size of the evidence item's RAM.
echo 'Where would you like to store the collected files? e.g. /Volumes/External Drive Name'
read StorageLocation
###Ask the user for the location of the volume root to collect data from. This should equate to 'cd /' on a live system.
echo 'Where do I find the root level of the machine to be collected from? e.g. /Volumes/OWC Aura SSD'
read CollectionLocation
###Create a log file form stdout and stderror. Note this will also create a verbose log of the files that couldn't have the xattributes copied.
exec &> >(tee -a "Darwin_Collection.log")
echo 'Darwin_Collection.log will be saved to script execution directory.'
cd $StorageLocation
###Startup Items
mkdir Startup-Items
cd Startup-Items
mkdir LAgents
mkdir SLAgents
mkdir Daemons
mkdir SDaemons
mkdir Items
cp -Rp "$CollectionLocation/Library/LaunchAgents/" ./LAgents
cp -Rp "$CollectionLocation/System/Library/LaunchAgents/" ./SLAgents
cp -Rp "$CollectionLocation/Library/LaunchDaemons/" ./Daemons
cp -Rp "$CollectionLocation/System/Library/LaunchDaemons/" ./SDaemons
cp -Rp "$CollectionLocation/Library/StartupItems/" ./Items
cp -Rp "$CollectionLocation/System/Library/StartupItems/" ./Items
cd ..
###############################################################################
###System Log Files
mkdir System-Logs
cd System-Logs
mkdir Log
mkdir ASL
mkdir Audit
mkdir Misc
cp -Rp "$CollectionLocation/var/log/" ./Log
cp -Rp "$CollectionLocation/var/log/asl/" ./ASL
cp -Rp "$CollectionLocation/var/audit/" ./Audit
cp -p "$CollectionLocation/var/log/install.log" ./
cp -Rp "$CollectionLocation/Library/Logs/" ./Misc
cd ..
###############################################################################
###System Preferences
mkdir System-Preferences
cd System-Preferences
cp -Rp "$CollectionLocation/Library/Preferences/" ./
cd ..
###############################################################################
###System Settings and Information
mkdir System-Settings
cd System-Settings
mkdir Password-Hashes
mkdir Cron-Jobs
mkdir Periodics
mkdir Network
cp -p "$CollectionLocation/var/db/.AppleSetupDone" ./
cp -p "$CollectionLocation/System/Library/CoreServices/SystemVersion.plist" ./
cp -Rp "$CollectionLocation/var/db/dslocal/nodes/Default/users/" ./Password-Hashes
cp -Rp "$CollectionLocation/usr/lib/cron/jobs/" ./Cron-Jobs
#cp -Rp "$CollectionLocation/etc/crontab" ./ #Doesn't appear to exist in High Sierra
cp -Rp "$CollectionLocation/usr/lib/cron/tabs/" ./Cron-Jobs
cp -p "$CollectionLocation/etc/localtime" ./
#cp -p "$CollectionLocation/etc/defaults/periodic.conf" ./ #Doesn't appear to exist in High Sierra
#cp -p "$CollectionLocation/etc/periodic.conf" ./ #Doesn't appear to exist in High Sierra
#cp -p "$CollectionLocation/etc/periodic.conf.local" ./ #Doesn't appear to exist in High Sierra
#cp -Rp "$CollectionLocation/etc/periodic/**2" ./Periodics #Doesn't appear to exist in High Sierra
#cp -Rp "$CollectionLocation/usr/local/etc/periodic/**2" ./Periodics #Doesn't appear to exist in High Sierra
#cp -Rp "$CollectionLocation/etc/daily.local/" ./Periodics #Doesn't appear to exist in High Sierra
#cp -Rp "$CollectionLocation/etc/weekly.local/" ./Periodics #Doesn't appear to exist in High Sierra
#cp -Rp "$CollectionLocation/etc/monthly.local/" ./Periodics #Doesn't appear to exist in High Sierra
cp -Rp "$CollectionLocation/etc/periodic/" ./Periodics
cp -p "$CollectionLocation/etc/hosts" ./Network
cp -p "$CollectionLocation/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist" ./Network
cd ..
###############################################################################
###Sleep and Hibr File
mkdir Sleep-Hibr-Files
cd Sleep-Hibr-Files
cp -p "$CollectionLocation/var/vm/sleepimage" ./
cp -p "$CollectionLocation/var/vm/swapfile#" ./
cd ..
###############################################################################
###Kernal Extensions
mkdir Kernal-Ext
cd Kernal-Ext
mkdir SystemExtensions
mkdir LibraryExtensions
cp -Rp "$CollectionLocation/System/Library/Extensions/" ./SystemExtensions
cp -Rp "$CollectionLocation/Library/Extensions/" ./LibraryExtensions
cd ..
###############################################################################
###Software Installation
mkdir Software-History
cd Software-History
cp -p "$CollectionLocation/Library/Receipts/InstallHistory.plist" ./
cp -p "$CollectionLocation/Library/Preferences/com.apple.SoftwareUpdate.plist" ./ #Does Not seem to exist in High Sierra
ls "$CollectionLocation/Applications/" >InstalledApps.txt
cd ..
###############################################################################
####Collect Data From Each User
###Create a list of users and store in a blog for calling. Will leave file in place to confirm all users were identified and reported on.
ls "$CollectionLocation/Users/" >users_temp.txt
###Use grep to remove the line for the defualt file '.localized' note, if a user can create an account with this name you will miss the hidden account. Comment out the next line and adjust hte previous line to 'users.txt' to compensate. If this script is run as sudo, such as on a line system, this line may not be removed.
grep -vwE ".localized" users_temp.txt > users.txt
###Clean the temp file.
rm users_temp.txt
###Start of the for loop to perform collection on artifacts for each user.
for Usr in $(cat users.txt); do
    ###Create directories for each user on the system
    mkdir $Usr
###Create a listing of the user's trash bin contents. Not collecting the contents at this time bu this can be switched to a 'cp -Rp' and pointed to storage location. Flags are used to sort and make distinctions on the data.
    ls -aCFlu "$CollectionLocation/Users/$Usr/.Trash/" >>"./$Usr/$Usr-Trash-Listing.csv"
    mkdir ./$Usr/iCloud-Accounts
    mkdir ./$Usr/User-Logs
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Application Support/iCloud/Accounts/" ./$Usr/iCloud-Accounts
    cp -p "$CollectionLocation/Users/$Usr/Library/Accounts/Accounts3.sqlite" ./$Usr
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Logs/" ./$Usr/User-Logs
    cp -p "$CollectionLocation/Users/$Usr/.bash_history" ./$Usr
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.loginitems.plist" ./$Usr
    mkdir $Usr/Keychains
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Keychains/" ./$Usr/Keychains
###Collect Mobile Device Sync Information
    mkdir ./$Usr/Mobile-Sync
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Application Support/MobileSync/Backup/" ./$Usr/Mobile-Sync
###Collect Recent Items History
    mkdir ./$Usr/Recent-Items
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.recentitems.plist" ./$Usr/Recent-Items
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/*LSSharedFileList.plist" ./$Usr/Recent-Items
###Collect User Preferences
    mkdir ./$Usr/User-Preferences
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Preferences/" ./$Usr/User-Preferences
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/MobileMeAccounts.plist" ./$Usr/User-Preferences
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.sidebarlists.plist" ./$Usr/User-Preferences
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/.GlobalPreferences.plist" ./$Usr/User-Preferences
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.Dock.plist" ./$Usr/User-Preferences
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.iPod.plist" ./$Usr/User-Preferences
###Collect Quarantine Events
    mkdir ./$Usr/Quarantine-Logs
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.LaunchServices.QuarantineEvents" ./$Usr/Quarantine-Logs
    cp -p "$CollectionLocation/Users/$Usr/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" ./$Usr/Quarantine-Logs
###Collect Skype Related Data
    mkdir ./$Usr/Skype-Data
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Application Support/Skype/" ./$Usr/Skype-Data
###Collect Safari Data
    mkdir ./$Usr/Safari-Data
###Opting to collect the entire tree rather than target artifacts.
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Safari/" ./$Usr/Safari-Data
###Collect Chrome Data
    mkdir ./$Usr/Chrome-Data
###Opting to collect the entire tree rather than target artifacts.
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Application Support/Google/Chrome/" ./$Usr/Chrome-Data
###Collect Firefox Data
mkdir FireFox-Data
    cp -Rp "$CollectionLocation/Users/$Usr/Library/Application Support/Firefox/" ./$Usr/FireFox-Data
done
































