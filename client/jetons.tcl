#!/usr/bin/tclsh

# Display jeton selection window
proc JETONS_DisplayJetons {} {
  variable game_state

  if { $game_state(player_turn) <= 8 } {
    DISCARD_CloseJetonWindow
  } elseif { ![winfo exists .board.jetons] } {
    toplevel .board.jetons -bd 0
    canvas .board.jetons.c -height 75 -width 220
    pack .board.jetons.c -expand 1 -side top -fill both
    catch {wm attributes .board.jetons -type tooltip}
    catch {wm attributes .board.jetons -toolwindow 1}
    wm protocol .board.jetons WM_DELETE_WINDOW "focus .board.jetons"
    wm attributes .board.jetons -topmost 1
    wm withdraw .board.jetons
    update
    if { [winfo exists .board.jetons] } {
      wm title .board.jetons "7 Wonders Duel - Choisir un jeton"
      wm transient .board.jetons .
      wm deiconify .board.jetons
      TOOLS_SetShortcuts .board.jetons
      update
      after 100 "catch { wm geometry .board.jetons +[BOARD_Scale 250]+[BOARD_Scale 250] }"
      catch { wm resizable .board.jetons 0 0 }
    }
    JETONS_UpdateJetons
  }
}

# Update jetons of the window
proc JETONS_UpdateJetons {} {
  variable SCRIPT_PATH
  variable game_state
  variable MODE_SEL

  # Manage card elements
  if { $game_state(player_turn) <= 8 } {
    JETONS_CloseWindow
  } elseif { [winfo exists .board.jetons] } {
    .board.jetons.c delete img_oval_jeton3
    for { set i 0 } { $i < 3 } { incr i } {
      .board.jetons.c delete img_jeton3_$i
      array set jeton [lindex $game_state(jeton3) $i]
      set img [image create photo]
      $img read "$SCRIPT_PATH/imgs/$jeton(image)"
      .board.jetons.c create image [expr (73 * $i) + 5] 5 -image $img -tags img_jeton3_$i -anchor nw
      if { ($MODE_SEL == 6) && ([GUI_IsPlaying] == 1) } {
        .board.jetons.c bind img_jeton3_$i <ButtonRelease-1> "ACTION_BuildWonderAndDiscard 6 -1 -1 -1 $i"
        .board.jetons.c bind img_jeton3_$i <Leave> "JETONS_HighlightJeton $i 0"
        .board.jetons.c bind img_jeton3_$i <Enter> "JETONS_HighlightJeton $i 1"
      } else {
        .board.jetons.c bind img_jeton3_$i <ButtonRelease-1> ""
        .board.jetons.c bind img_jeton3_$i <Enter> ""
      }
    }
  }
}

# Close window
proc JETONS_CloseWindow {} {
  if { [winfo exists .board.jetons] } { destroy .board.jetons }
}

# Jeton highlighting
proc JETONS_HighlightJeton {index value} {
  variable JETON3_INDEX
  variable MODE_SEL

  if { $value    == 0 } { set JETON3_INDEX -1 }
  if { $MODE_SEL != 6 } { return }
  if { $value    == 1 } { set JETON3_INDEX $index }
}


