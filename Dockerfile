ARG UBUNTU_IMAGE=ubuntu:26.04@sha256:2260313b31c8c011cd2eebe728008efac1b3982be73eb71348ea2648d2c0e09b
FROM ${UBUNTU_IMAGE}

ARG IMAGE_VERSION=v0.1.2
ARG SOURCE_REVISION=unknown

LABEL org.opencontainers.image.title="PastureStack/kubernetes-data-helper-image" \
      org.opencontainers.image.description="One-shot data-volume helper maintained by PastureStack." \
      org.opencontainers.image.source="https://github.com/PastureStack/kubernetes-data-helper-image" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${SOURCE_REVISION}" \
      org.opencontainers.image.base.name="docker.io/library/ubuntu:26.04"

COPY LICENSE /usr/share/licenses/pasturestack-kubernetes-data-helper-image/LICENSE

RUN rm -f /usr/bin/pebble

USER 65532:65532
ENTRYPOINT ["/bin/true"]
