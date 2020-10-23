# clever_munki

# Automatically build a Munki Server or configure client side settings

* This will automatically setup and install a munki server. Also included is an uninstaller that will undo any of the changes created by the builder script.
* Configures client side settings.
* Munki Version: 5.1.1.4112

## Prereqs

* OSX not running Server app.
* The script will also attempt to install the following:
    * homebrew
    * wget

## Instructions

* Set permissions on the script to allow it to run `sudo chmod a+x munki_builder.sh`
* The machine will require a restart after installation.
* After restart, check to see that the munki structure is setup (http://localhost/munki_repo).

## Client side build Instructions

* Please have the following information on hand before running script:
    * URL/IP address of your munki repo
    * The name of your munki repo (default is munki_repo)
    * Set permissions on the script to allow it to run `sudo chmod a+x munki_client_builder.sh`


## Uninstall Instructions

* Works under assumption that default settings were used during installation.
* Set permissions on the uninstall script to allow it to run `sudo chmod a+x munki_remove.sh`
    * Removes munki configs and cache data
    * Removes munki repo, restores apache files and settings, removes sym links regarding munki.
