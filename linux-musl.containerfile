from alpine:latest as Base

RUN apk update

RUN apk add --no-cache meson ninja-build zip unzip gcc make atools automake \
	autoconf libtool musl-dev linux-headers libexpat expat-dev expat-static

from Base as Build

WORKDIR /build

ENTRYPOINT ["sh", "build_wayland.sh", "linux-musl"]

