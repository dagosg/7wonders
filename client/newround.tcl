#!/usr/bin/tclsh

# Display first player selection window
proc NEWROUND_DisplayNewRound {} {
  variable PLAYER_NAME
  variable GUI_UPDATED

  if { [TOOLS_IsNewRound $PLAYER_NAME] == 0 } {
    NEWROUND_CloseWindow
  } elseif { ![winfo exists .board.newround] } {
    toplevel .board.newround -bd 0
    button .board.newround.btn1 -text "Je souhaite commencer le nouveau round"     -height 1 -bd 0 -command "NEWROUND_StartRound me"
    button .board.newround.btn2 -text "Je souhaite laisser l'adversaire commencer" -height 1 -bd 0 -command "NEWROUND_StartRound other"
    pack .board.newround.btn1 .board.newround.btn2 -expand 1 -side top -fill x
    catch {wm attributes .board.newround -type tooltip}
    catch {wm attributes .board.newround -toolwindow 1}
    wm protocol .board.newround WM_DELETE_WINDOW "focus .board.newround"
    wm attributes .board.newround -topmost 1
    wm withdraw .board.newround
    update
    if { [winfo exists .board.newround] } {
      wm title .board.newround "7 Wonders Duel - Nouveau round"
      wm transient .board.newround .
      wm deiconify .board.newround
      TOOLS_SetShortcuts .board.newround
      update
      after 100 "catch { wm geometry .board.newround +[BOARD_Scale 250]+[BOARD_Scale 250] }"
      catch { wm resizable .board.newround 0 0 }
    }
  }
  if { ([winfo exists .board.newround]) && ($GUI_UPDATED < 0) } {
    focus .board.newround
  }
}

# Close window
proc NEWROUND_CloseWindow {} {
  if { [winfo exists .board.newround] } { destroy .board.newround }
}

# Start the round
proc NEWROUND_StartRound {player} {
  variable tcp_socket

  NEWROUND_CloseWindow
  catch { puts $tcp_socket "StartRound $player" }
}

