#!/bin/bash
: '
Only use this script if you installed munki using default values. Otherwise, edit the code as needed in the `munki_remove_repo` function.

'

# Remove munkitools, configs and cache data.
munki_remove() {
echo "Removing munkitools, its configs and cache data."    
sudo launchctl unload /Library/LaunchDaemons/com.googlecode.munki.*

sudo rm -rf "/Applications/Utilities/Managed Software Update.app"
sudo rm -rf "/Applications/Managed Software Center.app"

sudo rm -f /Library/LaunchDaemons/com.googlecode.munki.*
sudo rm -f /Library/LaunchAgents/com.googlecode.munki.*
sudo rm -rf "/Library/Managed Installs"
sudo rm -f /Library/Preferences/ManagedInstalls.plist
sudo rm -rf /usr/local/munki
sudo rm /etc/paths.d/munki

sudo pkgutil --forget com.googlecode.munki.admin
sudo pkgutil --forget com.googlecode.munki.app
sudo pkgutil --forget com.googlecode.munki.core
sudo pkgutil --forget com.googlecode.munki.launchd
sudo pkgutil --forget com.googlecode.munki.app_usage
}

munki_remove_repo(){
    echo "Removing munki repo..."
    sudo rm -rf /Users/Shared/munki_repo 

    echo "Removing sym links from '/Library/WebServer/Documents/munki_repo'"
    sudo unlink /Library/WebServer/Documents/munki_repo

    echo "Restoring apache httpd file..."
    sudo cp /etc/apache2/httpdbak.conf /etc/apache2/httpd.conf

    echo "Restarting apache service to reflect changes..."
    sudo apachectl restart 

    echo "Stopping apache service..."
    sudo apachectl stop

}
munki_remove
munki_remove_repo