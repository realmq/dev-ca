# Docker Dev Certificates
`dev-ca` is a docker image for generating self signed root and leaf certificates for local development.
It makes it easy to manage and use local dev certificates.

* Manage generation of local root certificate.
* Trusted once, you can use any domain locally with TLS enabled.
* Supporting wild-card domains
* Also supporting IP addresses.
* Dev certs won't expire in a lifetime
* Build with/for docker
* Use anywhere via convenient CLI tool

## Generate certificates

* Dev certificates are generated for a main domain (**DOMAIN** defaults to `localhost`).
* They can be issued for any number of alternative domains and ip addresses (**SAN** defaults to `127.0.0.1`)

### Use with docker :whale:
Generate dev certificates to local directory via docker:

```bash
mkdir -p certificates
docker run --rm \
    -v "${PWD}/certificates:/data/certificates" \
    -u $(id -u ${user}):$(id -g ${user}) \
    -e DOMAIN="my-org.local" \
    realmq/dev-ca
```

* `-u $(id -u ${user}):$(id -g ${user})` makes sure your certificates are accessible by current user. If you omit this option certificates are owned by `root:root`.
* You can include additional domains and ip-addresses by passing them via `-e SAN="another.tld 10.10.0.1"`

### Use convenient CLI tool :computer:

Install our [cli wrapper](https://github.com/realmq/dev-ca/blob/master/dev-ca.sh):

```bash
sudo curl -L https://raw.githubusercontent.com/realmq/dev-ca/master/dev-ca.sh -o /usr/local/bin/dev-ca
sudo chmod a+rx /usr/local/bin/dev-ca
```

Use the CLI tool to generate local dev certificates:
```bash
dev-ca --domain="my-org.local"
```

* Specify main domain via `-d|--domain` parameter. (Defaults to `localhost`)
* Pass alternative names via `-s|--san` parameter. (Defaults to `${HOSTNAME} 127.0.0.1`)
* Set destination directory via `-v|--volume` parameter. (Defaults to `${CWD}/certificates`)
* Set owning user via `-u|--user` parameter. (Defaults to `${USER}`)

## Roadmap

* Add documentation on how to install/trust self-signed root certificates
* Add docker compose setup example for nginx tls termination

## License
Copyright (c) 2019 [RealMQ GmbH](https://realmq.com).<br />
The files in this archive are released under the [MIT License](LICENSE).
