# docker-php

Commands run as the non-root `app` user. On startup, `app` adopts the non-root owner UID of `/app/src` and receives ownership of `/app` and the certificate directories, so bind mounts owned by arbitrary UIDs such as GitHub Actions' 1001 remain writable.

Use the named `app` user rather than an explicit unknown `--user` identity. A root-owned `/app/src` keeps the image's default UID 1000.
