#!/bin/bash
###################################################################################################################
#
# Author 	: 	Rendla Venu
#
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
HOSTSFILE=hosts
GITHUBUSER=StevenBlack
GITHUBREPO=hosts
URLRAWBASE=https://raw.githubusercontent.com/$GITHUBUSER/$GITHUBREPO/master
META_DIR=META-INF/com/google/android
PREVIOUS_BUILDS=previous_builds
OUTFILE=brokenAds_$(date +'%Y%m%d_%s').zip
DEV=$(whoami)

start=$(date +%s)

if [[ -d $META_DIR  && -d $PREVIOUS_BUILDS ]]
then
    echo "Directory already exists." 
    
    touch $META_DIR/updater-script
   
    echo "Move any old  zip files to previous_builds"
    find . -maxdepth 1 -iname 'brokenAds_*.zip' -exec mv {} $PREVIOUS_BUILDS \; 
else
    echo "Directory  does not exists. \n Creating the path..."
    
    mkdir -p $META_DIR && (touch $META_DIR/updater-script)
    
    mkdir -p $PREVIOUS_BUILDS;
    echo "Move any old  zip files to previous_builds"
    find . -maxdepth 1 -iname 'brokenAds_*.zip' -exec mv {} $PREVIOUS_BUILDS \; 

fi


echo "********************************* Initiating fresh build ********************************************"

echo "Fetching  host records from github  - $GITHUBUSER"
wget -q $URLRAWBASE/$HOSTSFILE -O - | sed -e '/^$/d' -e '/^[ \t]*#/d' -e 's/#.*$//' -e 's/ *$//' -e '/0\.0\.0\.0$/d' | sort -k2 | uniq >> $HOSTSFILE


echo "# Host file is created by $DEV at $(date)" > $HOSTSFILE
echo  "Creating binary files..."

cat <<- EOF > $META_DIR/update-binary
			#!/sbin/sh
			export OUTFD="/proc/self/fd/\$2"
			ui_print() {
				echo "ui_print \$1" > "\$OUTFD"
			}

			ui_print "Zip updated: $(date)"
			ui_print ""
			ui_print "Updating hosts file..."
			ui_print "Detecting system mountpoint..."
			system_as_root='getprop ro.build.system_root_image'
			if [ "\$system_as_root" == "true" ]; then
			 SYSTEM_MOUNT=/system_root
			else
			 SYSTEM_MOUNT=/system
			fi
			ui_print "Mounting system..."
			mount "\$SYSTEM_MOUNT"
			ui_print "Extracting temp files..."
			cd /tmp; mkdir adfreezip; cd adfreezip;
			unzip -o "\$3"
			ui_print "Copy hosts file..."
			cp ./hosts "\$SYSTEM_MOUNT/etc/"
			cp ./hosts "\$SYSTEM_MOUNT/system/etc/"
			ui_print "Cleaning up..."
			rm /tmp/adfreezip -rf
			ui_print "Done, unmounting system..."
			umount \$SYSTEM_MOUNT
	EOF




echo "Building package ..."
zip $OUTFILE -r META-INF $HOSTSFILE
echo "Build is complete. Zip file is located at $(pwd)/$OUTFILE"
end=$(date +%s)
runtime=$((end-start)) 
echo "Build process time - $runtime sec"