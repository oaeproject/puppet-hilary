#!/usr/bin/sh

##
# Upgrade the pkgsrc repos on a Joyent SmartOS 64-bit machine
##

PKG_PATH=http://pkgsrc.joyent.com/sdc6/2012Q1/x86_64/All pkg_add smtools
sm-rebuild-pkgsrc