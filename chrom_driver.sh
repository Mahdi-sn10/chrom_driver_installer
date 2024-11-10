#!/bin/bash

change_dns() {
    echo "Changing DNS servers..."
    sed -i '/^DNS=/d' /etc/systemd/resolved.conf
    sed -i '/^FallbackDNS=/d' /etc/systemd/resolved.conf
    echo "DNS=$1" >> /etc/systemd/resolved.conf
    echo "FallbackDNS=$2" >> /etc/systemd/resolved.conf
    systemctl restart systemd-resolved
    echo "DNS servers updated successfully!"
    to_log user INFO "Changed DNS to $1 and $2"
}

function to_log() {
    local FACILITY=$1
    local LOG_LEVEL=$2
    shift 2
    local MSG=$@
    logger -s -i -t to_log -p ${FACILITY}.${LOG_LEVEL} "$MSG"
}

function check_is_update() {
    curl -s https://developer.chrome.com/docs/chromedriver/downloads\#chromedriver_1140573516 | grep -E 'ChromeDriver ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' > file_2.txt
    line=$(sed -n '1p' file_2.txt)
    Path=./my_version.txt
    my_version=$(sed -n '1p' "$Path")
    rm file_2.txt
    
    if [ ! -e "$Path" ]; then
        echo 1
        echo "$line" > my_version.txt 
        to_log user INFO "Installed new version: $line"
    elif [ "$my_version" = "$line" ]; then
        echo 0
        to_log user INFO "ChromeDriver is up to date: $my_version"
    else 
        echo 1
        echo "$line" > my_version.txt 
        to_log user INFO "Updated to new version: $line"
    fi
}

function download_chrom() {
    VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
    curl -O https://chromedriver.storage.googleapis.com/$VERSION/chromedriver_linux64.zip
    unzip -o chromedriver_linux64.zip
    mv chromedriver /usr/local/bin/
    chmod +x /usr/local/bin/chromedriver
    to_log user INFO "Downloaded and installed ChromeDriver version: $VERSION"
}

change_dns 178.22.122.100 185.51.200.2
result=$(check_is_update)
if [ "$result" -eq 1 ]; then
    download_chrom
else 
    echo "Your ChromeDriver is up to date"
fi
