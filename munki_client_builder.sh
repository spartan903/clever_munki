#!/bin/bash

# For installing client side only

#Grabbing munkitools
munki_installer() {
programsneeded=(brew wget)
stuffitems=${programsneeded[*]}

for item in $stuffitems
  do
    if [ -e /usr/local/bin/$item ]; then
      echo "$item already installed."
    else
      case $item in
        brew)
            echo "Installing Homebrew..."
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		    wait
            echo "Homebrew Installed!"
        ;;
		    wget)
            echo "Installing wget..."
	  		    brew install wget
			      wait
            echo "wget Installed!"
		    ;;
      esac
	fi
  done

echo "Changing to '/tmp' folder"
cd /tmp
read -p "Please enter the version number (Hit Enter to install 3.6.2.3776 ): " pkg_url
if [ "$pkg_url" == "" ]; then
pkg_url="3.6.2.3776"
sudo wget https://github.com/munki/munki/releases/download/v3.6.2/munkitools-3.6.2.3776.pkg
else
sudo wget https://github.com/munki/munki/releases/download/v3.6.2/munkitools-${pkg_url}.pkg
fi

#Installing Munkitoolset
sudo installer -pkg /tmp/munkitools-${pkg_url}.pkg -target /
sudo rm /tmp/munkit*
PATH=$PATH\:/usr/local/munki ; export PATH
}

echo "Installing pre-reqs..."
munki_installer
echo "Pre-reqs installed!"

# Setting variables for munki url
read -p "What is the URL/IP where Munki is hosted? " munki_url
read -p "What is the repo name (Leave empty to default to 'munki_repo')? " munki_repo_name

if [ "$munki_repo_name" == "" ]; then
munki_repo_name="munki_repo"
else
echo "munki repo name set to $munki_repo_name."
fi

# Saving typing time
defaults_path="/Library/Preferences/ManagedInstalls"
software_repo_url="http://$munki_url/$munki_repo_name"
apple_update_flag="InstallAppleSoftwareUpdates"
#Set to either 0 for False, 1 for true
munki_apple_updates="1"

# Setting the SoftwareRepoURL 
echo "Setting Software Repo to: $software_repo_url."
sudo defaults write $defaults_path SoftwareRepoURL $software_repo_url
confirm_repo_url=$(defaults read /Library/Preferences/ManagedInstalls SoftwareRepoURL)

# Setting the Client Identifier
read -p "What is the Client Identifier?: " munki_client_id
echo "Setting the Client Identifier to: $munki_client_id".
sudo defaults write $defaults_path ClientIdentifier $munki_client_id
confirm_repo_client_id=$(defaults read /Library/Preferences/ManagedInstalls ClientIdentifier)

# Setting Apple Updates
# Uncomment below if Apple Updates are included in Munki's updates
# sudo defaults write $defaults_path $apple_update_flag $munki_apple_updates

#Settings so far
echo "Here are your current settings: "
echo "SoftwareRepoURL: $confirm_repo_url"
echo "ClientIdentifier: $confirm_repo_client_id" 

#Refreshing Managed Software Center
osascript -e 'quit app "Managed Software Center"'
sudo managedsoftwareupdate

if [[ $(ls /Applications/ | grep Managed) == "" ]]; then
echo "Please open MSC to see new changes, if any."
else
open /Applications/"Managed Software Center.app"
fi

