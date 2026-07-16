# docker-php

The image runs as the non-root `app` user (`1000:1000`). Arbitrary UIDs can use GID 0 (for example, `user: "4711:0"`) to write application files and update the trusted CA bundle.

Linux bind mounts must already be writable by the selected UID. Custom certificates can be mounted into `/usr/local/share/ca-certificates` and are trusted during container startup.
