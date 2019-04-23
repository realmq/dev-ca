#!/bin/sh
set -a
: ${TLD=dev.local}
: ${SAN_DEFINITION=""}
set +a

: ${SAN=""}
: ${CONF_PATH="/data/config"}
: ${CERT_PATH="/data/certificates"}
: ${ROOT_CERT_EXPIRATION_DAYS=36500}
: ${LEAF_CERT_EXPIRATION_DAYS=36500}

export SAN="$TLD $SAN"
set -a
ALT_NAMES="$(./format-san.sh)"
set +a

root_cnf="${CONF_PATH}/root.cnf"
leaf_cnf="${CONF_PATH}/leaf.cnf"

tld_cnf="${CERT_PATH}/${TLD}_tld.txt"
root_key="${CERT_PATH}/root.key.pem"
root_csr="${CERT_PATH}/root.csr.pem"
root_crt="${CERT_PATH}/root.crt.pem"
root_srl="${CERT_PATH}/root.srl"
leaf_key="${CERT_PATH}/${TLD}.key.pem"
leaf_csr="${CERT_PATH}/${TLD}.csr.pem"
leaf_crt="${CERT_PATH}/${TLD}.crt.pem"

if [ ! -f "$root_cnf" ]
then
  echo "ERR: missing root config: $root_cnf" 1>&2
  exit 1;
fi

if [ ! -f "$leaf_cnf" ]
then
  echo "ERR: missing leaf config: $leaf_cnf" 1>&2
  exit 1;
fi

# save used tld
if [ ! -f "$tld_cnf" ]
then
  echo "$ALT_NAMES" > "$tld_cnf"

elif [ "$ALT_NAMES" != "$(cat "$tld_cnf")" ]
then
  echo "$ALT_NAMES" > "$tld_cnf"
fi

# create root key
if [ ! -f "$root_key" ]
then
  openssl genrsa -out "$root_key" 4096
fi

# create root csr
# when no csr, key newer than csr, conf newer then csr
if [ ! -f "$root_csr" -o "$root_key" -nt "$root_csr" -o "$root_cnf" -nt "$root_csr" ]
then
  openssl req -new -out "$root_csr" -key "$root_key" -config "$root_cnf"
fi

# create root crt
# when no crt, csr newer than crt, conf newer then crt
if [ ! -f "$root_crt" -o "$root_csr" -nt "$root_crt" -o "$root_cnf" -nt "$root_crt" ]
then
  openssl x509 -req -days 36500 -in "$root_csr" -signkey "$root_key" -out "$root_crt" -extensions v3_ca -extfile "$root_cnf"
fi

# create leaf key
if [ ! -f "$leaf_key" ]
then
  openssl genrsa -out "$leaf_key" 4096
fi

# create leaf csr
# when no csr, key newer than csr, conf newer then csr, tld conf newer then csr
if [ ! -f "$leaf_csr" -o "$leaf_key" -nt "$leaf_csr" -o "$leaf_cnf" -nt "$leaf_csr" -o "$tld_conf" -nt "$leaf_csr" ]
then
  openssl req -new -out "$leaf_csr" -key "$leaf_key" -config "$leaf_cnf"
fi

# create leaf crt
# when no crt, csr newer than crt, conf newer then crt, root crt newer then crt
if [ ! -f "$leaf_crt" -o "$leaf_csr" -nt "$leaf_crt" -o "$root_cnf" -nt "$leaf_crt" -o "$root_crt" -nt "$leaf_crt" ]
then
  openssl x509 -req -days 36500 -in "$leaf_csr" -CA "$root_crt" -CAkey "$root_key" -CAserial "$root_srl" -CAcreateserial -out "$leaf_crt" -extensions v3_server_cert -extfile "$leaf_cnf"
fi
