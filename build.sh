set -eu

podman build -f linux-musl.containerfile -t wayland-static-musl
podman run --replace -v "$(pwd)":/build --rm --name WaylandStaticBuilder wayland-static-musl

podman build -f linux-glibc.containerfile -t wayland-static-glibc
podman run --replace -v "$(pwd)":/build --rm --name WaylandStaticBuilder wayland-static-glibc


