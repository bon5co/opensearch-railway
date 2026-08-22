FROM opensearchproject/opensearch@sha256:bcc1797519726ceb6d651d4a3e60b7c30da91793914a8dfe75fd441d4f641509

USER root

# Railway terminates TLS at its edge and speaks plain HTTP to the container, so the
# security plugin's HTTP-layer TLS has to be off while its authentication stays on.
ENV discovery.type=single-node \
    bootstrap.memory_lock=false \
    plugins.security.ssl.http.enabled=false

COPY --chmod=0755 railway-entrypoint.sh /usr/local/bin/railway-entrypoint

ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
CMD ["opensearch"]
