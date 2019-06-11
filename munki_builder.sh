#!/bin/bash

check_shared_dir () {
    echo "Checking for /Shared directory....."
    if [ -d /Users/Shared ]; then
    echo "Shared folder found."
    sudo chmod 1777 /Users/Shared
    else
    printf "Shared folder not found. \nCreating it in '/Users' and setting permissions.\n"
    sudo mkdir /Users/Shared
    sudo chmod 1777 /Users/Shared 
    fi
}

munki_repo_build () {
    echo "Building munki_repo in '/Users/Shared/ .....'"
    cd /Users/Shared
    mkdir munki_repo

    # Building necessary folders
    folders_needed=(catalogs icons manifests pkgs pkgsinfo)
    stuff_items=${folders_needed[*]}

    for item in $stuff_items
      do 
        mkdir munki_repo/$item
      done    
    
    sudo chmod 755 munki_repo
}

enable_apache_index () {
    
    echo "Enabling Indexing on Apache..."
    #Backing up httpd.conf file
    echo "Backing up /etc/apache2/httpd.conf to /etc/apache2/httpdbak.conf"
    sudo cp /etc/apache2/httpd.conf /etc/apache2/httpdbak.conf
    
    # Checking for Homebrew and grabbing gnu-sed due to sed commands in OSX not working like Linux.
    : '
    #This part should work, but I cant get why it doesnt. Im pretty bad. 
    
    programs_needed=(brew gsed)
    
    stuffprograms=${programs_needed[*]}
    for items in $stuffprograms
      do
        if [ -e /usr/local/bin/$items ]; then
          echo "$items already installed."
        else
          case $items in
            brew)
              echo "Installing Homebrew..."
              /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
              wait
              echo "Homebrew installed."
            ;;
            gsed)
              echo "Brewing gsed ..."
              brew install gnu-sed
              echo "gsed installed."
              alias sed=gsed
            ;;
          esac
        fi 
      done
    '
    echo "Checking for Homebrew..."
    if [ -e /usr/local/bin/brew ]; then
      echo "Homebrew installed."
    else
      echo "Homebrew not found. Installing Homebrew..."
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 
      wait
      echo "Homebrew installed."
    fi

    #gsed is needed because Mac version of sed doesn't work as well
    echo "Checking for gsed..."
    if [ -e /usr/local/bin/gsed ]; then
      echo "gsed installed."
    else
      echo "gsed not found. Brewing..."
      brew install gnu-sed
      alias sed=gsed
      echo "gsed installed."
    fi

    sudo gsed -i 's/Options FollowSymLinks Multiviews/Options Indexes FollowSymLinks Multiviews/g' /etc/apache2/httpd.conf
}
apache_work () {
    echo "Allowing Apache to read and traverse munki directories"
    #Allow apache to read and traverse munki directory
    cd /Users/Shared
    sudo chmod -R a+rX munki_repo

    echo "Setting sym links to repo"
    #Allow Apache to serve munki repo directory via HTTP using sym links
    sudo ln -s /Users/Shared/munki_repo /Library/Webserver/Documents
}

# Munki Installer
munki_installer () {

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
sudo rm /tmp/munkitools*
}

#This function requires functions 'check_shared_dir', 'munki_repo_build', 'apache_work', 'enable_apache_index', ''
munki_buildmenow(){
check_shared_dir
munki_installer
munki_repo_build

check_apachectl=$(ps -ax | grep apachectl)
if [[ -z $check_apachectl ]]; then
  apache_work
  enable_apache_index
  echo "Starting Apache Service..."
  sudo apachectl start
else
  echo "Stopping apache service..."
  sudo apachectl stop 
  apache_work
  enable_apache_index
  echo "Starting Apache again..."
  sudo apachectl start
fi

restart_function
}

restart_function() {
    while true; do
        read -p "Computer requires a restart. Do you want to restart now? (Y or N): " restartchoice
            case $restartchoice in
                [Yy] )
                    echo "Restarting"
                        sudo reboot
                        break;;
                [Nn] )
                    echo "Please restart using 'sudo reboot'"
                        break;;
                *)
                    echo "Please choose Y or N.";;
            esac
    done
}


# Main Section
munki_buildmenow