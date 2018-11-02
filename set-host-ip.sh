#!/bin/bash
#
# Add or update an ip address in /etc/hosts file
# Originally based on https://stackoverflow.com/a/37824076/1269643
#

if [ $# -ne 2 ]; then
    echo $0: usage: hostname ip_address
    exit 1
fi

# insert/update hosts entry
HOSTNAME="$1"
IP_ADDRESS="$2"

if [[ ! $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "${IP_ADDRESS} is not a valid IPv4 address"
    exit 1
fi

# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $HOSTNAME /etc/hosts | cut -f1 -d:)"
host_entry="${IP_ADDRESS} ${HOSTNAME}"

echo "Please enter your password if requested."

if [ ! -z "$matches_in_hosts" ]
then
    echo "Updating existing hosts entry."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
        # replace the text of each line with the desired host entry
        sudo sed -i "${line_number}s/.*/${host_entry}/" /etc/hosts
    done <<< "$matches_in_hosts"
else
    echo "Adding new hosts entry."
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
fi

