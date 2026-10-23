ARG UBUNTU_IMAGE=ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b
FROM ${UBUNTU_IMAGE} AS snapshot-ca-bootstrap

ADD --checksum=sha256:5b6326f1932cfd7be57130561dc78192f09ed9f58bfbe6606ed0c50510c3b6cd \
    https://archive.ubuntu.com/ubuntu/pool/main/c/ca-certificates/ca-certificates_20260816ubuntu0.26.04.1_all.deb \
    /tmp/ca-certificates.deb
RUN set -eux; \
    mkdir -p /tmp/ca-bootstrap; \
    dpkg-deb --extract /tmp/ca-certificates.deb /tmp/ca-bootstrap; \
    find /tmp/ca-bootstrap/usr/share/ca-certificates -type f -name '*.crt' | LC_ALL=C sort | \
        while IFS= read -r certificate; do sed -e '$a\' "${certificate}"; done > /snapshot-ca-bundle.crt; \
    test -s /snapshot-ca-bundle.crt

FROM ${UBUNTU_IMAGE}

ARG IMAGE_VERSION=v0.1.3
ARG SOURCE_REVISION=unknown

LABEL org.opencontainers.image.title="PastureStack/kubernetes-data-helper-image" \
      org.opencontainers.image.description="One-shot data-volume helper maintained by PastureStack." \
      org.opencontainers.image.source="https://github.com/PastureStack/kubernetes-data-helper-image" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${SOURCE_REVISION}" \
      org.opencontainers.image.base.name="docker.io/library/ubuntu:26.04"

COPY LICENSE /usr/share/licenses/pasturestack-kubernetes-data-helper-image/LICENSE

COPY --from=snapshot-ca-bootstrap /snapshot-ca-bundle.crt /tmp/security-ca-bundle.crt
COPY ubuntu-security-packages.lock /usr/share/pasturestack/security/ubuntu-security-packages.lock
COPY scripts/install-ubuntu-security-updates.sh /tmp/install-ubuntu-security-updates.sh
RUN set -eux; \
    sh /tmp/install-ubuntu-security-updates.sh /usr/share/pasturestack/security/ubuntu-security-packages.lock /tmp/security-ca-bundle.crt; \
    rm -f /usr/bin/pebble /tmp/security-ca-bundle.crt /tmp/install-ubuntu-security-updates.sh; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*; \
    rm -f /var/log/apt/* /var/log/dpkg.log /var/log/alternatives.log /var/cache/ldconfig/aux-cache

USER 65532:65532
ENTRYPOINT ["/bin/true"]
