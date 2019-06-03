# clever_munki

# Automatically build a Munki Server

* This will automatically setup and install a munki server. Also included is an uninstaller that will undo any of the changes created by the builder script. This assumes that script will be run on a machine not running the Server.app.

* Instructions
    * Set permissions on the script to allow it to run `sudo chmod a+x munki_builder.sh`
    * The machine will require a restart after installation
    * After restart, check to see that the munki structure is setup (http://localhost/munki_repo)
    * Run the uninstall script if you wish to remove munki server from your system 