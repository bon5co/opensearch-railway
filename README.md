# opensearch-railway

OpenSearch 3.8.0, wrapped so it actually deploys on [Railway](https://railway.com).

Upstream's image cannot run on Railway unmodified. Three things are in the way, and this
wrapper fixes each one:

1. **Railway mounts volumes owned by root, and OpenSearch runs as uid 1000.** The node dies at
   startup with `AccessDeniedException: /usr/share/opensearch/data/nodes`. The entrypoint takes
   ownership of the data directory as root, then hands the process to the unprivileged
   `opensearch` user (OpenSearch refuses to run as root).
2. **Railway terminates TLS at its edge and speaks plain HTTP to the container.** The security
   plugin's HTTP-layer TLS is therefore turned off while its authentication stays on, so the
   cluster still answers `401 Unauthorized` to anonymous requests.
3. **An unset admin password must not become an open cluster.** The entrypoint refuses to boot
   without `OPENSEARCH_INITIAL_ADMIN_PASSWORD` rather than exposing a public search index.

`GET /_plugins/_security/health` answers `200` without credentials, which makes it the correct
Railway healthcheck path — every other endpoint is behind authentication.

## Variables

| Variable | Purpose |
| --- | --- |
| `OPENSEARCH_INITIAL_ADMIN_PASSWORD` | **Required.** Needs upper, lower, digit and a special character. |
| `OPENSEARCH_JAVA_OPTS` | Heap. `-Xms512m -Xmx512m` keeps the container inside 1 GB. |
| `PORT` | `9200`. |
