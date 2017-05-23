#! /bin/sh

# <codex>
# <abstract>Script to remove everything installed by the sample.</abstract>
# </codex>

# This uninstalls everything installed by the sample.  It's useful when testing to ensure that 
# you start from scratch.

# Remove HelperTool
sudo launchctl unload /Library/LaunchDaemons/com.alexost.fileinfoapp.FileProcessorTool.plist
sudo rm /Library/LaunchDaemons/com.alexost.fileinfoapp.FileProcessorTool.plist
sudo rm /Library/PrivilegedHelperTools/com.alexost.fileinfoapp.FileProcessorTool

# Remove app support
sudo rm -r $HOME/Library/Application\ Support/com.alexost.fileinfoapp

sudo security -q authorizationdb remove "com.alexost.fileinfoapp.FileProcessorTool"

