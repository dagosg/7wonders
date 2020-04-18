#!/usr/bin/tclsh
package require Tk

# Main window
wm title . "7 Wonders Duel"
wm withdraw .
wm geometry  . "800x600+200+100"
wm resizable . 0 0
set game_state(version_server_compatibility) "2"
set game_state(player_turn)   -1
set game_state(player_first)  ""
set game_state(player_second) ""
set game_state(play)          ""
set forever 1
after 100 "GUI_ManageTurn"

# First step: display connexion dialog
proc GUI_DisplayGui {} {
  variable TCP_PORT
  variable TCP_HOST
  variable PLAYER_OBS
  variable PLAYER_NAME

  if { ![winfo exists .connexion] } {
    toplevel .connexion -bd 4
    wm protocol .connexion WM_DELETE_WINDOW "GUI_Close .connexion"
    wm withdraw .connexion
    update
    if { [winfo exists .connexion] } {
      wm resizable .connexion 1 0
      wm title .connexion "7 Wonders Duel - Rejoindre une partie"
      wm transient .connexion .
      wm deiconify .connexion
      label       .connexion.l1 -text "Parametres de connexion" -font bold
      frame       .connexion.fc
      frame       .connexion.fc.f1 -bd 4
      label       .connexion.fc.f1.l1 -text "Serveur:"
      label       .connexion.fc.f1.l2 -text "Port:"
      frame       .connexion.fc.f2 -bd 4
      text        .connexion.fc.f2.t1 -height 1
      text        .connexion.fc.f2.t2 -height 1
      .connexion.fc.f2.t1 insert 1.0 "$TCP_HOST"
      bind .connexion.fc.f2.t1 <<Modified>> { GUI_ManageButtonState }
      .connexion.fc.f2.t2 insert 1.0 "$TCP_PORT"
      bind .connexion.fc.f2.t2 <<Modified>> { GUI_ManageButtonState }
      label       .connexion.l2 -text "Parametres du joueur" -font bold
      frame       .connexion.fp
      frame       .connexion.fp.f1 -bd 4
      label       .connexion.fp.f1.l1 -text "Nom du joueur:"
      label       .connexion.fp.f1.l2 -text "Mode observateur:"
      frame       .connexion.fp.f2 -bd 4
      text        .connexion.fp.f2.t1 -height 1
      .connexion.fp.f2.t1 insert 1.0 "$PLAYER_NAME"
      bind .connexion.fp.f2.t1 <<Modified>> { GUI_ManageButtonState }
      checkbutton .connexion.fp.f2.chk -text "Oui" -anchor w -variable PLAYER_OBS
      button      .connexion.ok -text "C'est parti!" -default active -command {GUI_ConnectToServer} -state disabled
      pack .connexion.l1 .connexion.fc .connexion.l2 .connexion.fp -side top -expand 1 -fill x
      pack .connexion.ok -side top -expand 0 -fill none
      pack .connexion.fc.f1 -side left -expand 0 -fill x
      pack .connexion.fc.f2 -side left -expand 1 -fill x
      pack .connexion.fc.f1.l1 .connexion.fc.f1.l2 -side top -expand 0 -fill x
      pack .connexion.fc.f2.t1 .connexion.fc.f2.t2 -side top -expand 1 -fill x
      pack .connexion.fp.f1 -side left -expand 0 -fill x
      pack .connexion.fp.f2 -side left -expand 1 -fill x
      pack .connexion.fp.f1.l1 .connexion.fp.f1.l2  -side top -expand 0 -fill x
      pack .connexion.fp.f2.t1 .connexion.fp.f2.chk -side top -expand 1 -fill x
      focus .connexion.fp.f2.t1
    }
  }
}

# Close window
proc GUI_CloseGui {} {
  if { [winfo exists .connexion] } { destroy .connexion }
}

# Update 'Let's Go' button state and lock text widgets
proc GUI_ManageButtonState {} {
  variable TCP_PORT
  variable TCP_HOST
  variable PLAYER_NAME

  set lastline [expr int([.connexion.fp.f2.t1 index "end - 1c"])]
  .connexion.fc.f2.t1 delete 2.0 end
  .connexion.fc.f2.t2 delete 2.0 end
  .connexion.fp.f2.t1 delete 2.0 end
  set TCP_HOST    [string trim [.connexion.fc.f2.t1 get 1.0 end]]
  set TCP_PORT    [string trim [.connexion.fc.f2.t2 get 1.0 end]]
  set PLAYER_NAME [string trim [.connexion.fp.f2.t1 get 1.0 end]]
  if { ($TCP_HOST == "") || ($TCP_PORT == "") || ($PLAYER_NAME == "") } {
    .connexion.ok configure -state disabled
  } else {
    .connexion.ok configure -state normal -default active
    if { $lastline > 1 } { GUI_ConnectToServer }
  }
  .connexion.fc.f2.t1 edit modified false
  .connexion.fc.f2.t2 edit modified false
  .connexion.fp.f2.t1 edit modified false
}

# Action: Server connexion
proc GUI_ConnectToServer {} {
  variable tcp_socket
  variable PLAYER_NAME
  variable PLAYER_OBS

  if { [ConnectServer] == "OK" } {
    catch { puts $tcp_socket "JoinGame {$PLAYER_NAME} $PLAYER_OBS" }
  }
}

# Display a dialog box
proc GUI_Dialog {title txt {top_window "."}} {
  variable MODE_SEL

  # Card selection
  set MODE_SEL 0
  set window $top_window
  if { $window == "." } { set window "" }
  if { ![winfo exists $top_window] } { return }
  if { [winfo exists $window.dialog] } { destroy $window.dialog }
  toplevel $window.dialog -bd 4
  catch {wm attributes $window.dialog -type tooltip}
  catch {wm attributes $window.dialog -toolwindow 1}
  label  $window.dialog.l  -text "$txt"
  button $window.dialog.ok -text OK -default active -command "destroy $window.dialog"
  pack $window.dialog.ok -side bottom -fill none
  pack $window.dialog.l  -expand 1    -fill both
  wm withdraw $window.dialog
  update
  if { [winfo exists $window.dialog] } {
    set x [expr (800-[winfo width  $window.dialog])/2]
    set y [expr (600-[winfo height $window.dialog])/2]
    after 100 "catch { wm geometry $window.dialog +$x+$y }"
    wm geometry  $window.dialog +1640+1480
    wm transient $window.dialog $top_window
    wm title     $window.dialog "$title"
    wm resizable $window.dialog 0 0
    wm deiconify $window.dialog
  }
}

# Display an information in the board
proc GUI_ShowInfo {txt color} {
  .board.c itemconfigure txt_info -fill "$color"
  .board.c itemconfigure txt_info -text "$txt"
}

# Update game state (from server)
proc GUI_UpdateGameState {game_state_list} {
  variable game_state
  variable GUI_UPDATED

  array set game_state [array set game_state $game_state_list]
  set GUI_UPDATED -2
}

# Close game
proc GUI_Close {window} {
  variable forever

  focus $window
  set answer [tk_messageBox -message "Voulez-vous quitter?" -icon question -parent $window -type yesno -title "Quitter le jeu"]
  if { $answer == "yes" } {
    set forever 0
    after 300 "destroy ."
  }
}

# Manage a turn
proc GUI_ManageTurn {} {
  variable game_state
  variable forever
  variable PLAYER_OBS
  variable MODE_SEL
  variable GUI_UPDATED

  # Manage Connexion window
  if { $game_state(player_turn) > 0 } {
    GUI_CloseGui
  }
  if { [winfo exists .connexion] } {
    if { $game_state(player_turn) >= 0 } {
      .connexion.fc.f2.t1  configure -state disabled
      .connexion.fc.f2.t2  configure -state disabled
      .connexion.fp.f2.t1  configure -state disabled
      .connexion.fp.f2.chk configure -state disabled
      .connexion.ok        configure -state disabled
    }
  }

  # Manage windows
  if { $game_state(player_turn) >= 0 } {
    BOARD_DisplayBoard
    BOARD_ManageInfoMessage
    WONDERS_DisplayWonders
    CHAT_DisplayChat
    DISCARD_UpdateDiscardCards
    NEWROUND_DisplayNewRound
    SCORE_DisplayScore
  }

  # To not update too often windows
  incr GUI_UPDATED
  if { $forever == 1 } { after 200 "GUI_ManageTurn" }
}

