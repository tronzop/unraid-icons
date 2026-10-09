# unraid-icons

Container icons for Tower's Unraid Docker page and the unraid-controller app.
Containers point at these through the `net.unraid.docker.icon` label:

    https://raw.githubusercontent.com/tronzop/unraid-icons/main/icons/<name>.png

`tools/make-icons.swift <src dir> <out dir>` renders them (512×512 PNG).
Brand artwork (mosquitto, Stirling-PDF, watchtower, UpSnap, PostgreSQL badge)
comes from [homarr-labs/dashboard-icons](https://github.com/homarr-labs/dashboard-icons).
