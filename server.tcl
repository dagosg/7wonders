#!/usr/bin/tclsh
set SCRIPT_PATH [file dirname [file normalize [info script]]]

# Server version
set SERVER_VERSION_MAJOR "2"
set SERVER_VERSION_MINOR "2"

# Load TLS library
source $SCRIPT_PATH/tls/tls.tcl
tls::initlib $SCRIPT_PATH/tls/x32 tls.so

# Load commands
source $SCRIPT_PATH/server/commands.tcl

# TCP port to listen
set tcp_port 8707

# If you want to use SSL on port 443 then you need to provide a pair of OpenSSL
# files for the keys. We setup the tls package here and below we can specify 
# what command to use to create the socket for each port.
if {[file exists $SCRIPT_PATH/server-public.pem]} {
        ::tls::init \
            -certfile $SCRIPT_PATH/server-public.pem \
            -keyfile $SCRIPT_PATH/server-private.pem \
            -ssl2 0 \
            -ssl3 0 \
            -require 0 \
            -request 1
}

namespace eval slaveServer {
  # procs that start with a lowercase letter are public
  namespace export {[a-z]*}
  variable serversocket
}

proc slaveServer::closeSocket {socket} {
  variable $socket
  upvar 0 $socket state

  # Deconnexion
  puts stderr "Closing $socket [clock format [clock seconds]]"
  catch {close $socket}
  unset state
}

# Get file contents in hexadecimal
proc slaveServer::ReadFile { filename } {
  # Open the file, and set up to process it in binary mode.
  set fp [open $filename r]
  fconfigure $fp -translation binary -encoding binary
  # Convert the data to hex and to characters.
  binary scan [read $fp] H* hex
  # When we're done, close the file.
  close $fp
  return $hex
}

# Send source code to client
proc slaveServer::SendSourceCode {socket} {
  # Send client source code (last version)
  set SCRIPT_PATH [file dirname [file normalize [info script]]]

  puts "Send source code to client..."
  foreach code_file {action board chat tools wonders discard jetons newround score} {
    set contents [slaveServer::ReadFile "$SCRIPT_PATH/client/$code_file.tcl"]
    catch { puts $socket "CLIENT_LoadSourceFile $contents" }
  }
  catch { flush $socket }
}

# This gets called whenever a client connects
proc slaveServer::Server {socket host port} {
  variable $socket
  upvar 0 $socket state

  # just to be sure ...
  array unset state
  set state(socket) $socket
  set state(host) $host
  set state(port) $port
  puts stderr "New Connection: $socket $host $port [clock format [clock seconds]]"

  # Configure socket
  fconfigure $socket -buffering line -blocking 0
  fileevent $socket readable [namespace code [list Handler $socket]]

  # Send source code to server
  slaveServer::SendSourceCode $socket
}

# This gets called whenever a client sends a new line
# of data or disconnects
proc slaveServer::Handler {socket} {
   variable $socket
   upvar 0 $socket state

   # Do we have a disconnect?
   if {[eof $socket]} {
       Disconnect
       return
   }

   # Does reading the socket give us an error?
   if {[catch {gets $socket line} ret] == -1} {
       puts stderr "Closing $socket"
       
       return
   }
   # Did we really get a whole line?
   if {$ret == -1} return

   # ... and is it not empty? ...
   if { [catch {
     set line [string trim $line]
   }] } {
     puts stderr "Error socket $socket"
     Disconnect
     return
   }
   if {$line == ""} return

   ## ... and not an SSL request? ...
   #if {[string index $line 0] == "\200"} {
   #    puts stderr "SSL request - closing connection"
   #    Disconnect
   #    return
   #}

   # OK, so log it ...
   if { "$line" != "TestConnexion" } { puts stderr "$socket > $line" }

   # ... evaluate it, ...
   if {[catch {slave eval $line} ret]} {
       set ret "ERROR: $ret"
   }
   # ... log the result ...
   if { "[regsub -all -line ^ $ret {}]" != "" } {
     puts stderr [regsub -all -line ^ $ret "$socket < "]
   }

   # ... and send it back to the client.
   if {[catch {puts $socket $ret}]} {
       Disconnect
   }
}

proc slaveServer::init {port commands} {
   variable serversockets

   # (re-)create a safe slave interpreter
   catch {interp delete slave}
   interp create -safe slave

   # remove all predefined commands from the slave
   foreach command [slave eval info commands] {
       slave hide $command
   }

   # link the commands for the protocol into the slave
   puts -nonewline stderr "Initializing commands:"
   foreach command $commands {
       puts -nonewline stderr " $command"
       interp alias slave $command {} $command
   }
   puts stderr ""

   #(re-)create the server socket
   if {[info exists serversockets]} {
       foreach sock $serversockets {
           catch {close $sock}
       }
       unset serversockets
   }
   puts stderr "Opening socket: $port"
   lappend serversockets [::tls::socket -server [namespace code Server] $port]
}

slaveServer::init $tcp_port $commands
if {![info exists forever]} {
  set forever 1
  vwait forever
}

