targetName="$1"
workerCount=$(($(nproc) * 2))

case "$targetName" in
	"linux-musl") echo "Musl build" ;;
	"linux-glibc") echo "Musl build" ;;
	*) echo "Invalid target: $targetName"; exit 1 ;;
esac

[ -z "$targetName" ] \

set -eu

BuildLibFFI(){
	cd /build
	rm -rf libffi-3.4.6
	unzip libffi-3.4.6.zip
	cd libffi-3.4.6

	./autogen.sh
	CFLAGS='-Os -fPIC' ./configure \
		--prefix="/usr/local" \
		--disable-docs \
		--enable-static \
		--disable-shared

	make -j$(workerCount) install

	mkdir -p LibFFI
	cp -v /usr/local/include/*.h \
		/usr/local/lib/*.a \
		LICENSE \
		LibFFI

	outputFile="LibFFI-$targetName.zip"
	zip -r -9 "$outputFile" LibFFI
	cp "$outputFile" /build
	cd /build

	rm -rf libffi-3.4.6
}

BuildWayland(){
	cd /build
	rm -rf wayland-1.23.1
	tar xvf wayland-1.23.1.tar.gz
	cd wayland-1.23.1

	meson setup build \
		--prefix=/usr/local \
		--default-library=static \
		-Dlibraries=true \
		-Dscanner=true \
		-Dtests=false \
		-Ddocumentation=false \
		-Ddtd_validation=false

	ninja -C build -j$workerCount install

	# Build Scanner only works on linux musl because glibc distros seem to just
	# hate convenience.
	if [ "$targetName" = "linux-musl" ]; then
		cd src/
		gcc scanner.c -Os -fPIC -flto -o wayland-scanner -lexpat -lwayland-client -static
		strip wayland-scanner
		cp wayland-scanner /usr/local/bin
		cd ..
	fi

	mkdir -p Wayland
	cp -v \
		/usr/local/lib/libwayland-client.a \
		/usr/local/lib/libwayland-server.a \
		/usr/local/lib/libwayland-cursor.a \
		/usr/local/lib/libwayland-egl.a \
		/usr/local/bin/wayland-scanner \
		/usr/local/include/wayland*.h \
		Wayland

	outputFile="Wayland-$targetName.zip"
	zip -r -9 "$outputFile" Wayland
	cp "$outputFile" /build
	cd /build

	rm -rf wayland-1.23.1
}

BuildLibFFI
BuildWayland

