#!/bin/tclsh
package provide app-7WondersDuelWin32 1.0

# Configure TLS
set TLS_DIR "x32"
set TLS_LIB "tls.dll"

# Run game
set SCRIPT_PATH [file dirname [file normalize [info script]]]
source $SCRIPT_PATH/client.tcl

