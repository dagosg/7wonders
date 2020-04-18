#!/bin/tclsh
package provide app-7WondersDuelMac 1.0

# Configure TLS
set TLS_DIR "x64"
set TLS_LIB "tls.dylib"

# Run game
set SCRIPT_PATH [file dirname [file normalize [info script]]]
source $SCRIPT_PATH/client.tcl

