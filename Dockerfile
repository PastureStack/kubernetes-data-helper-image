# syntax=docker/dockerfile:1.7
ARG UBUNTU_IMAGE=ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b
ARG UBUNTU_SECURITY_BACKPORTS_IMAGE=ghcr.io/pasturestack/ubuntu-security-backports:v0.1.0@sha256:2742a3d429e4e14bc587f6dedc51ded4246cf90bbaedcd86c67d0885e32a6f2a

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

FROM ${UBUNTU_SECURITY_BACKPORTS_IMAGE} AS ubuntu_security_backports

FROM ${UBUNTU_IMAGE}
ARG UBUNTU_SECURITY_BACKPORTS_IMAGE

ARG IMAGE_VERSION=v0.1.4
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

# Keep the build-only installer and package archives outside the final image.
RUN --mount=type=bind,from=ubuntu_security_backports,source=/out,target=/opt/pasturestack/ubuntu-security-backports,readonly \
    set -eux; \
    evidence=/usr/share/pasturestack/security/ubuntu-backports; \
    mkdir -p "$evidence"; \
    /opt/pasturestack/ubuntu-security-backports/install-existing-backports --install-in-docker-build > "$evidence/install.json"; \
    /opt/pasturestack/ubuntu-security-backports/install-existing-backports --verify-installed > "$evidence/verify.json"; \
    for file in manifest.json qualification.json source-inputs.lock.json openvex.json; do \
        cp "/opt/pasturestack/ubuntu-security-backports/$file" "$evidence/$file"; \
    done; \
    printf '%s\n' "$UBUNTU_SECURITY_BACKPORTS_IMAGE" > "$evidence/bundle-image.txt"; \
    (cd "$evidence" && sha256sum manifest.json qualification.json source-inputs.lock.json openvex.json install.json verify.json bundle-image.txt > SHA256SUMS)

USER 65532:65532
ENTRYPOINT ["/bin/true"]
