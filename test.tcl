#!/usr/bin/tclsh
set SCRIPT_PATH [file dirname [file normalize [info script]]]

# Server connexion
set TCP_PORT "8707"
set TCP_HOST localhost
set PLAYER_NAME "PlayerTest[pid]"
set PLAYER_OBS 0

# TLS configuration
if { ![info exists TLS_DIR] } { set TLS_DIR "x32" }
if { ![info exists TLS_LIB] } { set TLS_LIB "tls.so" }

# Test sources
source $SCRIPT_PATH/client.tcl

# Start test
GUI_ConnectToServer

