FROM alpine

LABEL \
  Name="Docker Dev Certificates" \
  Description="Docker image for generating self signed certificates for local development." \
  Vendor="RealMQ GmbH <service@realmq.com>" \
  Version="0.1.0"

RUN apk add --no-cache openssl

COPY leaf.cnf root.cnf /data/config/
COPY generate.sh /generate.sh
COPY format-san.sh /format-san.sh

VOLUME /data/certificates
CMD /generate.sh
