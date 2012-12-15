#! /bin/sh

PIXMAN_VER=0.28.2
CAIRO_VER=1.12.8

cd /tmp
curl http://www.cairographics.org/releases/pixman-$PIXMAN_VER.tar.gz -o pixman.tar.gz
tar -zxf pixman.tar.gz && cd pixman-$PIXMAN_VER/
./configure --prefix=/usr/local --disable-dependency-tracking
sudo make install

cd /tmp
curl http://cairographics.org/releases/cairo-$CAIRO_VER.tar.xz -o cairo.tar.gz
tar -zxf cairo.tar.gz && cd cairo-$CAIRO_VER
./configure --prefix=/usr/local --disable-dependency-tracking
sudo make install
