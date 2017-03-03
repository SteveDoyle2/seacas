#! /usr/bin/env bash

### The following assumes you are building in a subdirectory of ACCESS Root
if [ "X$ACCESS" == "X" ] ; then
  ACCESS=$(cd ../../..; pwd)
  echo "ACCESS set to ${ACCESS}"
fi

rm -f config.cache
CC='gcc'; export CC
CFLAGS="-I${ACCESS}/include"; export CFLAGS
CPPFLAGS='-DNDEBUG'; export CPPFLAGS

# Find hdf5 library...
LDFLAGS="-L${ACCESS}/lib"; export LDFLAGS
SHARED="--enable-shared"

./configure --with-hdf5=${ACCESS} --enable-mat73 ${SHARED} --prefix=${ACCESS} $1

echo ""
echo "COMPILER: ${CC}"
echo "  ACCESS: ${ACCESS}"
echo ""
