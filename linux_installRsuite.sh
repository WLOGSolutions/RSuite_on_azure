#!/bin/bash

# Install RSuite on ubuntu version.
# To see more check: www.rsuite.io
REPO="https://wlog-rsuite.s3.amazonaws.com/cli/"

echo "RSuite install script started... Downloading files..." 
wget https://wlog-rsuite.s3.amazonaws.com/cli/PKG_INDEX -P /tmp

if [ -f  /etc/debian_version ]; then pkg_name=`cat /tmp/PKG_INDEX | grep deb: | sed -e "s/^.*: \([^\r\n]*\).*$/\1/"`; fi
if [ -f  /etc/system-release-cpe ]; then pkg_name=`cat /tmp/PKG_INDEX | grep rpm: | sed -e "s/^.*: \([^\r\n]*\).*$/\1/"`; fi
if [ -z "$pkg_name" ]; then
	echo "Unsupported platform"
	exit 1
fi

wget $REPO$pkg_name -P /tmp
echo "Download complete... Preceding to installation."
pkg_file=`echo $pkg_name | sed -e "s/^.*\/\(.*\)$/\1/"`

yes | aptdcon --hide-terminal --install "/tmp/$pkg_file"

# If you don't have aptdcon on your machine try:
#until apt-get install -y /tmp/$pkg_file
#do
#  echo "My time has not come, retry in 2 secs..."
# sleep 2
#done

ret_code="$?"
if [ ret_code -e 0 ]; then
   echo "RSuite installed successfully."
else
   echo "Process returned code: ${ret_code}."; fi

echo "Installing R package for RSuite."
rsuite install -v

echo "Check if everything is installed properly. Version: "
echo $(rsuite version)

echo "Cleaning up after install..."

rm /tmp/$pkg_file
rm /tmp/PKG_INDEX

echo "Finished..."