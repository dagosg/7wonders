#!/usr/bin/tclsh
set SCRIPT_PATH [file dirname [file normalize [info script]]]
source $SCRIPT_PATH/gui.tcl

# Server connexion
if { ![info exists TCP_PORT] } { set TCP_PORT "8707" }
if { ![info exists TCP_HOST] } { set TCP_HOST "localhost" }

# TLS configuration
if { ![info exists TLS_DIR] } { set TLS_DIR "x32" }
if { ![info exists TLS_LIB] } { set TLS_LIB "tls.so" }

# Player configuration
if { ![info exists PLAYER_NAME] } { set PLAYER_NAME "" }
if { ![info exists PLAYER_OBS] }  { set PLAYER_OBS 0 }

# Load TLS library
source $SCRIPT_PATH/tls/tls.tcl
tls::initlib $SCRIPT_PATH/tls/$TLS_DIR $TLS_LIB

# Load TCL code of a file
proc CLIENT_LoadSourceFile {filedata} {
  variable tcp_socket
  variable SCRIPT_PATH

  # Code load configuration
  set fp [file tempfile]
  fconfigure $fp -translation binary -encoding binary
  puts $fp [binary format H* $filedata]
  seek $fp 0
  eval [read $fp]
  close $fp
}

# Connect to the server
proc ConnectServer {} {
  variable SCRIPT_PATH
  variable TCP_HOST
  variable TCP_PORT
  variable TLS_DIR
  variable TLS_LIB
  variable tcp_socket

  # Connect to server
  if { [ catch {
    set tcp_socket [::tls::socket $TCP_HOST $TCP_PORT]
  } err ] } {
    GUI_Dialog "Erreur de connexion" "Erreur de connexion à $TCP_HOST sur le port $TCP_PORT:\n$err" ".connexion"
    return "KO"
  }

  # Command configuration
  fconfigure $tcp_socket -buffering line -blocking 0
  fileevent $tcp_socket readable [list Handler $tcp_socket]
  return "OK"
}

proc Handler {socket} {
   #variable $socket

   # Do we have a disconnect?
   if {[eof $socket]} {
       close $socket
       return
   }

   # Does reading the socket give us an error?
   if {[catch {gets $socket line} ret] == -1} {
       puts stderr "Closing $socket"
       close $socket
       return
   }
   # Did we really get a whole line?
   if {$ret == -1} return

   # ... and is it not empty? ...
   set line [string trim $line]
   if {$line == ""} return

   # Execute command
   eval $line
}

GUI_DisplayGui

