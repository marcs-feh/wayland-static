from ubuntu:jammy as Base

RUN apt update -y

RUN apt install -y meson ninja-build zip unzip gcc make automake autoconf libtool libexpat1 libexpat1-dev linux-headers-generic pkgconf

from Base as Build

WORKDIR /build

ENTRYPOINT ["sh", "build_wayland.sh", "linux-glibc"]

