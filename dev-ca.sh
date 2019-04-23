#!/usr/bin/env bash

user="${USER}"
domain="localhost"
san="${HOSTNAME} 127.0.0.1"
volume="$(pwd)/certificates"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -u) user="$2"; shift 2;;
    -d) domain="$2"; shift 2;;
    -s) san="$2"; shift 2;;
    -v) volume="$2"; shift 2;;

    --user=*) user="${1#*=}"; shift 1;;
    --domain=*) domain="${1#*=}"; shift 1;;
    --san=*) san="${1#*=}"; shift 1;;
    --volume=*) volume="${1#*=}"; shift 1;;
    --user|--domain|--san|--volume) echo "$1 requires an argument" >&2; exit 1;;

    *) echo "unknown option: $1" >&2; exit 1;;
  esac
done

echo "Creating dev certificate for ${domain}"
echo "Including ${san}"
echo "Running as user ${user}"
echo "Writing certificates to ${volume}"

$(docker run --rm -v ${volume}:/data/certificates -u $(id -u ${user}):$(id -g ${user}) -e TLD=${domain} -e SAN="${san}" realmq/dev-ca)

echo ""
echo "🙌 Certificates have been generated!"
echo "------------------------------------"
echo "🥇 Root Certificate: ${volume}/root.cert.pem"
echo "🥇 Root Keyfile: ${volume}/root.key.pem"
echo "🍁 Leaf Certificate: ${volume}/${domain}.crt.pem"
echo "🍁 Leaf Keyfile: ${volume}/${domain}.key.pem"
