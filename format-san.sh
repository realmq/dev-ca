#!/usr/bin/env sh

: ${SAN=""}

formatted_san=""

while
    # read the first dns or ip from SAN input
    # split input by comma, colon and space
    IFS=";, " read -r dnsOrIp SAN <<INPUT
        $SAN
INPUT

    # check for empty string (eg. SAN="some.tld;;;another.tld")
    if [ "${dnsOrIp}n" != "n" ] ; then
        # check if $dnsOrIp matches
        isIp=$(echo $dnsOrIp | grep -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}\b')

        if [ "${formatted_san}n" != "n" ] ; then
            formatted_san="${formatted_san},"
        fi

        if [ "${isIp}n" != "n" ] ; then
            # add to san definition as IP record
            formatted_san="${formatted_san}IP:${dnsOrIp}"
        else
            # add to san definition as DNS record
            formatted_san="${formatted_san}DNS:${dnsOrIp}"
        fi
    fi

    # continue as long as there are more sans
    [ "${SAN}n" != "n" ]
do :; done

echo $formatted_san
