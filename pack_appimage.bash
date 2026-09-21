#!/bin/bash
set -e

APPIMAGE_NAME="$1"
if [ -z "$APPIMAGE_NAME" ]; then
  APPIMAGE_NAME="reliquary-archiver-x86_64.AppImage"
fi

mkdir -p AppDir/usr/bin \
  AppDir/usr/lib \
  AppDir/usr/share/icons/hicolor/256x256/apps \
  AppDir/usr/share/applications

cat >AppDir/AppRun <<EOF
#!/bin/sh
set -e
HERE="$(dirname "$(readlink -f "$0")")"
APPIMAGE_LIB_DIRS="$HERE/usr/lib:$HERE/usr/lib/x86_64-linux-gnu"
export LD_LIBRARY_PATH="$APPIMAGE_LIB_DIRS:/lib/x86_64-linux-gnu:/usr/lib/x86_64-linux-gnu:/usr/lib"
exec "$HERE/usr/bin/reliquary-archiver" "$@"
EOF
chmod +x AppDir/AppRun

cat >AppDir/usr/share/applications/reliquary-archiver.desktop <<EOF
[Desktop Entry]
Type=Application
Name=reliquary-archiver
Exec=reliquary-archiver
Icon=reliquary-archiver
Terminal=true
Categories=Utility;
EOF
chmod +x AppDir/usr/share/applications/reliquary-archiver.desktop

cp target/release/reliquary-archiver AppDir/usr/bin/
chmod +x AppDir/usr/bin/reliquary-archiver

cp assets/icon256.png AppDir/usr/share/icons/hicolor/256x256/apps/reliquary-archiver.png
LIBPCAP_PATH=$(ldconfig -p | grep "libpcap.so" | awk '{print $NF}' | head -n 1)
cp "$LIBPCAP_PATH" AppDir/usr/lib/

cd AppDir
ln -s usr/share/icons/hicolor/256x256/apps/reliquary-archiver.png reliquary-archiver.png
ln -s usr/share/applications/reliquary-archiver.desktop reliquary-archiver.desktop
cd ..

curl -L -o appimagetool.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool.AppImage

./appimagetool.AppImage AppDir "$APPIMAGE_NAME"
