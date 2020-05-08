#!/usr/bin/tclsh

# Chat window
proc CHAT_DisplayChat {} {
  variable game_state
  variable chat_text
  variable chat_message
  variable tcp_socket
  variable PLAYER_NAME
  variable ZOOM_IN
  variable ZOOM_OUT
  variable GUI_UPDATED

  if { ![winfo exists .board.chat] } {
    toplevel .board.chat -bd 2
    set chat_text    ".board.chat.fc.t"
    set chat_message ".board.chat.fm.t"
    frame       .board.chat.fc -bd 2
    text        .board.chat.fc.t -state disabled -yscrollcommand {.board.chat.fc.s set} -height 1 -width 10
    scrollbar   .board.chat.fc.s -command {.board.chat.fc.t yview}
    frame       .board.chat.fm -padx 4
    text        .board.chat.fm.t -height 1 -width 5
    button      .board.chat.fm.btn -text "ENVOYER" -default active -command { CHAT_SendChatMessage } -padx 2 -pady 0 -borderwidth 0
    button      .board.chat.fm.clr -text "X" -command { CHAT_Clear } -padx 2 -pady 0 -borderwidth 0  -relief flat
    wm protocol .board.chat WM_DELETE_WINDOW "GUI_Close .board.chat ; catch {wm attributes .board.chat -type tooltip} ; catch {wm attributes .board.chat -toolwindow 1} ; catch {wm attributes .board.chat -topmost 1}"
    catch {wm attributes .board.chat -type tooltip}
    catch {wm attributes .board.chat -toolwindow 1}
    wm attributes .board.chat -topmost 1
    wm withdraw .board.chat
    update
    if { [winfo exists .board.chat] } {
      wm title .board.chat "7 Wonders Duel - Chat & Suivi"
      wm transient .board.chat .
      wm deiconify .board.chat
      after 100 "CHAT_SetSize"
      bind .board.chat.fm.t <<Modified>> { CHAT_PrepareMessage }
      pack .board.chat.fc -side top -expand 1 -fill both
      pack .board.chat.fm -side top -expand 0 -fill x
      pack .board.chat.fc.t -side left -expand 1 -fill both
      pack .board.chat.fc.s -side left -expand 0 -fill y
      pack .board.chat.fm.t   -side left -expand 1 -fill x
      pack .board.chat.fm.btn .board.chat.fm.clr -side left -expand 0 -fill none
      TOOLS_SetShortcuts .board.chat
      update
      foreach player $game_state(player_list) {
        if { "[lindex $player 0]" != "$PLAYER_NAME" } {
          CHAT_DisplayMessage "[lindex $player 0] est connecté" "black"
        }
      }
      catch { puts $tcp_socket "SendChatMessage {Je suis connecté}" }
      CHAT_DisplayMessage "Commandes du jeu:"                     "slate blue"
      CHAT_DisplayMessage "F2 - Sauvegarder la partie"            "slate blue"
      CHAT_DisplayMessage "F3 - Recharger la partie"              "slate blue"
      CHAT_DisplayMessage "F5 - Raffraîchir (bug/déconnexion)"    "slate blue"
      CHAT_DisplayMessage "F6 - Coup précédent"                   "slate blue"
      CHAT_DisplayMessage "F7 - Coup suivant"                     "slate blue"
      CHAT_DisplayMessage "F10 - Nouvelle partie"                 "slate blue"
      CHAT_DisplayMessage "F12 - Tuer le server (blocage)"        "slate blue"
    }
  }
  if { ([winfo exists .board.chat]) && ($GUI_UPDATED < 0) } {
    focus .board.chat.fm.t
  }
  CHAT_CheckTimeouts
}

# Set chat size and position
proc CHAT_SetSize {} {
  variable ZOOM_IN
  variable ZOOM_OUT

  if { [winfo exists .board.chat] } {
    wm geometry .board.chat [BOARD_Scale 400]x[BOARD_Scale 820]+[BOARD_Scale 1205]+20
  }
}

# Indicate someone is typing
variable TTAG
variable TYPING
variable TTIME
if { ![info exists TTAG] } {
  set TTAG   -1
  set TYPING {}
  set TTIME  {}
}
proc CHAT_IsTyping {name} {
  variable TYPING
  variable TTAG
  variable TTIME
  variable chat_text

  # Create tag if none
  if { $TTAG == -1 } {
    # First tag
    set TTAG [CHAT_DisplayMessage "$name est en train d'écrire" "black" 0]
  }

  # Append people typing
  set index [lsearch -exact $TYPING $name]
  if { $index == -1 } {
    lappend TYPING $name
    lappend TTIME [clock milliseconds]
  } else {
    # Just update time
    set TTIME [lreplace $TTIME $index $index [clock milliseconds]]
  }

  # Update typing information
  CHAT_UpdateTypingInfo
}

# Update typing information
proc CHAT_UpdateTypingInfo {} {
  variable TTAG
  variable TYPING
  variable chat_text

  if { $TTAG != -1 } {
    # If empty, clear typing info
    if { [llength $TYPING] == 0 } {
      CHAT_ClearTypingInfo
    } else {
      # Update content
      $chat_text configure -state normal
      $chat_text delete tag$TTAG.first "tag$TTAG.last - 1c"
      $chat_text configure -state disabled
      set loop [expr [llength $TYPING] - 1]
      set names "[lindex $TYPING 0]"
      for { set i 1 } { $i < $loop } { incr i } {
        set names "$names, [lindex $TYPING $i]"
      }
      if { $loop > 0 } {
        set names "$names et [lindex $TYPING $loop] sont en train d'écrire..."
      } else {
        set names "$names est en train d'écrire..."
      }
      set TTAG [CHAT_DisplayMessage "$names" "black" 0]
    }
  }
}

# Check timeouts
proc CHAT_CheckTimeouts {} {
  variable TYPING
  variable TTIME

  set upd 0
  set new_typing {}
  set new_ttime  {}
  for { set i 0 } { $i < [llength $TYPING] } { incr i } {
    set elapsed [expr [clock milliseconds] - [lindex $TTIME $i]]
    if { $elapsed > 1500 } {
      set upd 1
    } else {
      lappend new_typing [lindex $TYPING $i]
      lappend new_ttime  [lindex $TTIME  $i]
    }
  }
  if { $upd == 1 } {
    set TYPING $new_typing
    set TTIME  $new_ttime
    CHAT_UpdateTypingInfo
  }
}

# Clear typing information
proc CHAT_ClearTypingInfo {} {
  variable TTAG
  variable TYPING
  variable TTIME
  variable chat_text

  # Clear typing information
  if { $TTAG != -1 } {
    $chat_text configure -state normal
    $chat_text delete tag$TTAG.first "tag$TTAG.last - 1c"
    $chat_text configure -state disabled
    set TTAG   -1
    set TYPING {}
    set TTIME  {}
  }
}

# Text modified
proc CHAT_PrepareMessage {} {
  variable chat_message
  variable tcp_socket

  # Detect a new line
  set last_index [$chat_message index "end - 1c"]
  set lastline [expr int($last_index)]
  if { $lastline > 1 } {
    CHAT_SendChatMessage
  } elseif { $last_index > 1.0 } {
    catch { puts $tcp_socket "IsTyping" }
  }
  $chat_message edit modified false
}

# Action: Send chat message
proc CHAT_SendChatMessage {} {
  variable tcp_socket
  variable chat_message

  set message "[string trim [$chat_message get 1.0 end]]"
  $chat_message delete 1.0 end
  if { "$message" != "" } {
    set message [string map {"\r" ""} $message]
    set lines [split $message "\n"]
    foreach line $lines {
      regsub -all "{" $line "\\{" line
      regsub -all "}" $line "\\}" line
      catch { puts $tcp_socket "SendChatMessage {$line}" }
    }
  }
}

# Display a new message
variable tagnb
if { ![info exists tagnb] } { set tagnb 0 }
proc CHAT_DisplayMessage {message color {cleartyping 1}} {
  variable chat_text
  variable tagnb

  # Clear typing information
  if { $cleartyping == 1 } { CHAT_ClearTypingInfo }

  if { [winfo exists .board.chat] } {
    regsub -all "\\\\{" $message "{" message
    regsub -all "\\\\}" $message "}" message
    $chat_text configure -state normal
    set idx [$chat_text index {end-1c}]
    $chat_text insert end "$message\n"
    $chat_text tag add tag$tagnb $idx end
    $chat_text tag configure tag$tagnb -foreground $color
    set font [$chat_text cget -font]
    $chat_text tag configure tag$tagnb -font "$font 10"
    $chat_text configure -state disabled
    $chat_text yview moveto 1.0
    set ret $tagnb
    incr tagnb
  }

  return $ret
}

# Clear chat
proc CHAT_Clear {} {
  variable chat_text
  variable tagnb
  variable TTAG

  if { [winfo exists .board.chat] } {
    $chat_text configure -state normal
    if { $TTAG != -1 } {
      $chat_text delete 0.0 tag$TTAG.first
    } else {
      $chat_text delete 0.0 end
    }
    $chat_text configure -state disabled
    $chat_text yview moveto 1.0
  }
}

