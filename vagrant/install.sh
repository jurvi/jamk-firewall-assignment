#!/usr/bin/env bash
echo "Checking if required software packages have been installed"
if [ ! -f "/home/vagrant/.installed" ]; then
	echo "Nope. Installing software packages now..."
	# Install required software packages for "add-apt-repository"
	apt-get install -y software-properties-common python-software-properties
	# Add jessie-backports repository for nftables
	add-apt-repository "deb http://mirrors.kernel.org/debian/ jessie-backports main contrib"
	# Update package list again because of jessie-backports addition
	apt-get update
	# Install nftables
	apt-get install -y nftables apache2
	# Set a symbolic link to point to nft
	ln -s /usr/sbin/nft /usr/bin/nft
	echo "Software installation OK! (Remove this file if there's need to run these scripts again.)" >> /home/vagrant/.installed
	echo "Required software packages installed succesfully"
else
	echo "Required software packages already installed."
fi
echo "Checking if nftables was already configured..."
if [ ! -f "/home/vagrant/.nftables" ]; then
	# Let's define a table first
	nft add table inet global
	# Add a chain input to the table. It's a filter chain that we hook onto input hook and it has a high priority.
	nft add chain inet global input { type filter hook input priority 0 \; }
	# Allow SSH (22)
	nft add rule inet global input tcp dport 22 accept
	# Allow also http (80)
	nft add rule inet global input tcp dport 80 accept
	# Drop all packets by default
	nft add rule inet global input drop
	echo "nftables configuration OK! (Remove this file if there's need to run these scripts again.)" >> /home/vagrant/.nftables
	echo "nftables configured succesfully"
else
	echo "nftables was already configured."
fi