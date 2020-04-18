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
    text        .board.chat.fm.t -height 1 -width 10
    button      .board.chat.fm.btn -text "ENVOYER" -default active -command { CHAT_SendChatMessage } -padx 2 -pady 0 -borderwidth 0 -relief flat
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
      pack .board.chat.fm.btn -side left -expand 0 -fill none
      TOOLS_SetShortcuts .board.chat
      update
      foreach player $game_state(player_list) {
        if { [lindex $player 0] != $PLAYER_NAME } {
          CHAT_DisplayMessage "[lindex $player 0] est connecte" "black"
        }
      }
      catch { puts $tcp_socket "SendChatMessage {Je suis connecte}" }
      CHAT_DisplayMessage "Commandes du jeu:"                     "slate blue"
      CHAT_DisplayMessage "F2 - Sauvegarder la partie"            "slate blue"
      CHAT_DisplayMessage "F3 - Recharger la partie"              "slate blue"
      CHAT_DisplayMessage "F5 - Raffraichir (bug/deconnexion)"    "slate blue"
      CHAT_DisplayMessage "F6 - Coup precedent"                   "slate blue"
      CHAT_DisplayMessage "F7 - Coup suivant"                     "slate blue"
      CHAT_DisplayMessage "F8 - Inversion du zoom"                "slate blue"
      CHAT_DisplayMessage "F10 - Nouvelle partie"                 "slate blue"
      CHAT_DisplayMessage "F12 - Tuer le server (blocage)"        "slate blue"
    }
  }
  if { ([winfo exists .board.chat]) && ($GUI_UPDATED < 0) } {
    focus .board.chat
  }
}

# Set chat size and position
proc CHAT_SetSize {} {
  variable ZOOM_IN
  variable ZOOM_OUT

  if { [winfo exists .board.chat] } {
    wm geometry .board.chat [BOARD_Scale 400]x[BOARD_Scale 820]+[BOARD_Scale 1205]+20
  }
}

# Text modified
proc CHAT_PrepareMessage {} {
  variable chat_message

  # Detect a new line
  set lastline [expr int([$chat_message index "end - 1c"])]
  if { $lastline > 1 } { CHAT_SendChatMessage }
  $chat_message edit modified false
}

# Action: Send chat message
proc CHAT_SendChatMessage {} {
  variable tcp_socket
  variable chat_message

  set message "[string trim [$chat_message get 1.0 end]]"
  $chat_message delete 1.0 end
  if { $message != "" } {
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
set tagnb 0
proc CHAT_DisplayMessage {message color} {
  variable chat_text
  variable tagnb

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
    incr tagnb
  }
}


