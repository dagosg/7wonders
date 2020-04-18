#!/usr/bin/tclsh

# Action card window
proc ACTION_DisplayActionCard {index} {
  variable SCRIPT_PATH
  variable game_state
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable MODE_SEL

  if { $MODE_SEL != 0 } { return }
  if { ![winfo exists .board.action_card] } {
    toplevel .board.action_card -bd 4
    frame .board.action_card.f1 -bd 2
    frame .board.action_card.f2 -bd 2
    frame .board.action_card.f3 -bd 2
    button .board.action_card.f1.take
    button .board.action_card.f2.discard -text "Defausser la carte"
    button .board.action_card.f3.wonder  -text "Construire une merveille"
    catch {wm attributes .board.action_card -type tooltip}
    catch {wm attributes .board.action_card -toolwindow 1}
    wm protocol .board.action_card WM_DELETE_WINDOW { ACTION_CloseActionCard }
    wm attributes .board.action_card -topmost 1
    wm withdraw .board.action_card
    update
    if { [winfo exists .board.action_card] } {
      wm title .board.action_card "7 Wonders Duel - Choisir une action"
      wm transient .board.action_card .
      wm deiconify .board.action_card
      pack .board.action_card.f1      .board.action_card.f2         .board.action_card.f3        -fill x -expand 1 -side top
      pack .board.action_card.f1.take .board.action_card.f2.discard .board.action_card.f3.wonder -fill x -expand 1
      TOOLS_SetShortcuts .board.action_card
      update
    }
  }

  # Manage action elements
  if { [winfo exists .board.action_card] } {
    wm resizable .board.action_card 1 1
    set price [TOOLS_GetCardPrice $index $PLAYER_NAME $PLAYER_OBS]
    if { $price == 0 } {
      .board.action_card.f1.take configure -text "Acheter la carte (gratuit)"
    } elseif { $price == -1 } {
      .board.action_card.f1.take configure -text "Acheter la carte par chainage (gratuit)"
      set price 0
    } else {
      .board.action_card.f1.take configure -text "Acheter la carte pour $price pieces d'or"
    }
    if { $PLAYER_NAME == $game_state(player_first)  } { set play "player_first"  }
    if { $PLAYER_NAME == $game_state(player_second) } { set play "player_second" }
    if { $price > $game_state(gold_$play) } {
      .board.action_card.f1.take configure -state disabled
    } else {
      .board.action_card.f1.take configure -state normal
    }
    if { ([TOOLS_GetLastWonder] == -1) && ([TOOLS_NbWonderBuilt $PLAYER_NAME] < 4) } {
      .board.action_card.f3.wonder configure -state normal
    } else {
      .board.action_card.f3.wonder configure -state disabled
    }

    # Test if the user have already the same green
    if { [TOOLS_CanTakeJeton $game_state(round) $index $PLAYER_NAME $PLAYER_OBS] == 1 } {
      .board.action_card.f1.take configure -command "ACTION_SelectJeton $index"
    } else {
      .board.action_card.f1.take configure -command "ACTION_SelectCard $index"
    }
    .board.action_card.f2.discard configure -command "ACTION_DiscardCard $index"
    .board.action_card.f3.wonder  configure -command "ACTION_SelectWonder $index"
    wm geometry .board.action_card 400x140+535+305
    wm resizable .board.action_card 0 0
  }
}

# Action wonder window
proc ACTION_DisplayActionWonder {index} {
  variable SCRIPT_PATH
  variable game_state
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable MODE_SEL

  if { $MODE_SEL != 1 } { return }
  if { ![TOOLS_IsWonderSelectable $PLAYER_NAME $index] } { return }
  if { ![winfo exists .board.action_wonder] } {
    toplevel .board.action_wonder -bd 4
    frame .board.action_wonder.f1 -bd 2
    button .board.action_wonder.f1.take
    catch {wm attributes .board.action_wonder -type tooltip}
    catch {wm attributes .board.action_wonder -toolwindow 1}
    wm protocol .board.action_wonder WM_DELETE_WINDOW { ACTION_CloseActionWonder }
    wm attributes .board.action_wonder -topmost 1
    wm withdraw .board.action_wonder
    update
    if { [winfo exists .board.action_wonder] } {
      wm title .board.action_wonder "7 Wonders Duel - Choisir une action"
      wm transient .board.action_wonder .
      wm deiconify .board.action_wonder
      pack .board.action_wonder.f1      -fill x -expand 1 -side top
      pack .board.action_wonder.f1.take -fill x -expand 1
      TOOLS_SetShortcuts .board.action_wonder
      update
    }
  }

  # Manage action elements
  if { [winfo exists .board.action_wonder] } {
    wm resizable .board.action_wonder 1 1
    set price [TOOLS_GetWonderPrice $index $PLAYER_NAME $PLAYER_OBS]
    if { $price == 0 } {
      .board.action_wonder.f1.take configure -text "Construire la merveille gratos"
    } else {
      .board.action_wonder.f1.take configure -text "Construire la merveille pour $price pieces d'or"
    }
    if { $PLAYER_NAME == $game_state(player_first)  } { set play "player_first"  }
    if { $PLAYER_NAME == $game_state(player_second) } { set play "player_second" }
    if { $price > $game_state(gold_$play) } {
      .board.action_wonder.f1.take configure -state disabled
    } else {
      .board.action_wonder.f1.take configure -state normal
    }
    .board.action_wonder.f1.take configure -command "ACTION_BuildWonder $index"
    wm geometry .board.action_wonder 400x50+535+305
    wm resizable .board.action_wonder 0 0
  }
}

# Close card window
proc ACTION_CloseActionCard {} {
  if { [winfo exists .board.action_card] } { destroy .board.action_card }
}

# Close wonder window
proc ACTION_CloseActionWonder {} {
  variable MODE_SEL

  set MODE_SEL 0
  BOARD_ManageInfoMessage
  if { [winfo exists .board.action_wonder] } { destroy .board.action_wonder }
  BOARD_DisplayBoard
}

# Card selection
proc ACTION_SelectCard {index {jeton -1}} {
  variable tcp_socket

  ACTION_CloseActionCard
  catch { puts $tcp_socket "TakeCard $index $jeton" }
}

# Card discard
proc ACTION_DiscardCard {index} {
  variable tcp_socket

  ACTION_CloseActionCard
  catch { puts $tcp_socket "DiscardCard $index" }
}

# Select wonder
proc ACTION_SelectWonder {index} {
  variable MODE_SEL
  variable MODE_SEL_CARD

  ACTION_CloseActionCard
  set MODE_SEL 1
  set MODE_SEL_CARD $index
  BOARD_ManageInfoMessage
}

# Build wonder
proc ACTION_BuildWonder {index} {
  variable MODE_SEL_WONDER
  variable MODE_SEL
  variable PLAYER_NAME
  variable PLAYER_OBS

  if { $MODE_SEL != 1 } { return }
  ACTION_CloseActionWonder
  set MODE_SEL_WONDER $index
  set MODE_SEL [TOOLS_GetWonderAction $index $PLAYER_NAME $PLAYER_OBS]
  BOARD_ManageInfoMessage
  if { $MODE_SEL == 1 } { ACTION_BuildWonderAndDiscard 1 }
  if { $MODE_SEL == 5 } { DISCARD_DisplayDiscardCards }
  if { $MODE_SEL == 6 } { JETONS_DisplayJetons }
}

# Build wonder and discard a card
proc ACTION_BuildWonderAndDiscard {mode {index -1} {lvl -1} {num -1} {jeton -1}} {
  variable MODE_SEL
  variable MODE_SEL_CARD
  variable MODE_SEL_WONDER
  variable tcp_socket

  if { $MODE_SEL != $mode } { return }
  if { $MODE_SEL == 5 } { DISCARD_CloseWindow }
  if { $MODE_SEL == 6 } { JETONS_CloseWindow  }
  set MODE_SEL 0
  catch { puts $tcp_socket "BuildWonder $MODE_SEL_CARD $MODE_SEL_WONDER $index $lvl $num $jeton" }
}

# Build wonder and discard a card
proc ACTION_BuildWonderAndRebirth {lvl num} {
  variable MODE_SEL
  variable MODE_SEL_CARDLVL
  variable MODE_SEL_CARDNUM
  variable PLAYER_NAME
  variable PLAYER_OBS

  if { $MODE_SEL != 5 } { return }
  set MODE_SEL_CARDLVL $lvl
  set MODE_SEL_CARDNUM $num
  if { [TOOLS_CanTakeJeton $lvl $num $PLAYER_NAME $PLAYER_OBS] == 0 } {
    ACTION_BuildWonderAndDiscard 5 -1 $MODE_SEL_CARDLVL $MODE_SEL_CARDNUM -1
  } else {
    DISCARD_CloseWindow
    set MODE_SEL 7
    BOARD_ManageInfoMessage
  }
}

# Select jeton
proc ACTION_SelectJeton {index} {
  variable MODE_SEL
  variable MODE_SEL_CARD

  ACTION_CloseActionCard
  set MODE_SEL 2
  set MODE_SEL_CARD $index
  BOARD_ManageInfoMessage
}

# Take jeton
proc ACTION_TakeJeton {index} {
  variable MODE_SEL
  variable MODE_SEL_CARD
  variable MODE_SEL_CARDLVL
  variable MODE_SEL_CARDNUM

  if { $MODE_SEL == 2 } {
    set MODE_SEL 0
    BOARD_ManageInfoMessage
    ACTION_SelectCard $MODE_SEL_CARD $index
  }
  if { $MODE_SEL == 7 } {
    ACTION_BuildWonderAndDiscard 7 -1 $MODE_SEL_CARDLVL $MODE_SEL_CARDNUM $index
  }
}



