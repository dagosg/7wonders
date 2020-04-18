#!/bin/bash
# Scipt used to build all stand-alone client binaries

# Generate a stand-alone binary
function generate {
  NAME=$1
  KIT=$2
  SUFFIX=$3

  # Generate structure
  ./sdx qwrap ./${NAME}.tcl
  ./sdx unwrap ./${NAME}.kit
  # Copy files
  cp ../client.tcl ./${NAME}.vfs/lib/app-${NAME}/
  cp ../gui.tcl    ./${NAME}.vfs/lib/app-${NAME}/
  cp -r ../tls     ./${NAME}.vfs/lib/app-${NAME}/
  cp -r ../imgs    ./${NAME}.vfs/lib/app-${NAME}/
  # Build binary
  ./sdx wrap ${NAME} -runtime ${KIT}
  # Move it at the right place
  DIR=`cat ./${NAME}.tcl | grep "TLS_DIR" | cut -d'"' -f2`
  if [ "${SUFFIX}" == "" ]
  then
    mv -f ./${NAME} ../bin/${DIR}/${NAME}
  else
    mv -f ./${NAME} ../bin/${DIR}/${NAME}.${SUFFIX}
  fi
  # Clean
  rm -rf ./${NAME}.vfs
  rm -f  ./${NAME}.kit
}

# Clean previous built
rm -rf ../bin

# Prepare generation
export PATH=$PATH:.
chmod u+x ./sdx ./tclkit
mkdir -p ../bin/x32
mkdir -p ../bin/x64
cp ../tls/x32/libssp-0.dll ../bin/x32/
cp ../tls/x64/libssp-0.dll ../bin/x64/
cp ../doc/* ../bin/x32/
cp ../doc/* ../bin/x64/

# For Windows x32
generate 7WondersDuelWin32 tclkit-8.6.10-win32.exe exe

# For Windows x64
generate 7WondersDuelWin64 tclkit-8.6.10-win64.exe exe

# For Linux x32
generate 7WondersDuelLnx32 tclkit-8.6.3-linux32

# For Linux x64
generate 7WondersDuelLnx64 tclkit-8.6.3-linux64

# For MAC
generate 7WondersDuelMac tclkit-8.6.3-mac

# Clean all
chmod u-x ./sdx ./tclkit

