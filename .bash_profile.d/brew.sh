#!/usr/bin/env bash
# All the stuff that brew recommended to add.

#export PATH="/usr/local/opt/gettext/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/gettext/lib"
export CPPFLAGS="-I/usr/local/opt/gettext/include"

#TODO: see bin/_configure_ -- add joining, beware of -I
#export CPPFLAGS="-I$(brew --prefix zlib)/include"
#TODO:  CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install -v 3.4.7

#export LDFLAGS="$LDFLAGS -L/usr/local/opt/sqlite/lib"
#export CPPFLAGS="$CPPFLAGS -I/usr/local/opt/sqlite/include"
#export PKG_CONFIG_PATH="/usr/local/opt/sqlite/lib/pkgconfig"
