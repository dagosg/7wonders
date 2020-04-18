#!/usr/bin/tclsh

# Display discard window
proc DISCARD_DisplayDiscardCards {} {
  variable GUI_UPDATED
  variable game_state

  if { $game_state(player_turn) <= 8 } {
    DISCARD_CloseWindow
  } elseif { ![winfo exists .board.discard] } {
    toplevel .board.discard -bd 0
    scrollbar .board.discard.scrollbar -orient horiz -command ".board.discard.c xview"
    canvas .board.discard.c -height 260 -width 550 -borderwidth 1 -xscrollcommand ".board.discard.scrollbar set"
    pack .board.discard.c       -expand 1 -side top -fill both
    pack .board.discard.scrollbar -expand 0 -side top -fill x
    catch {wm attributes .board.discard -type tooltip}
    catch {wm attributes .board.discard -toolwindow 1}
    wm protocol .board.discard WM_DELETE_WINDOW "DISCARD_CloseWindow"
    wm attributes .board.discard -topmost 1
    wm withdraw .board.discard
    update
    if { [winfo exists .board.discard] } {
      wm title .board.discard "7 Wonders Duel - Explorer la defausse"
      wm transient .board.discard .
      wm deiconify .board.discard
      TOOLS_SetShortcuts .board.discard
      update
      after 100 "catch { wm geometry .board.discard +[BOARD_Scale 250]+[BOARD_Scale 250] }"
      catch { wm resizable .board.discard 1 0 }
    }
    set GUI_UPDATED -1
    DISCARD_UpdateDiscardCards
  }
}

# Update cards of the window
proc DISCARD_UpdateDiscardCards {} {
  variable SCRIPT_PATH
  variable game_state
  variable GUI_UPDATED
  variable MODE_SEL

  # Manage card elements
  if { $game_state(player_turn) <= 8 } {
    DISCARD_CloseWindow
  } elseif { ([winfo exists .board.discard]) && ($GUI_UPDATED < 0) } {
    .board.discard.c delete img_rect_discard img_last_discard
    set nb_cards 0
    for { set i 0 } { $i < 60 } { incr i } { .board.discard.c delete img_dcards$i }
    for { set j 1 } { $j <= 3 } { incr j } {
      for { set i 0 } { $i < 20 } { incr i } {
        array set card [lindex $game_state(cards$j) $i]
        if { $card(owner) == "discard" } {
          set img [image create photo]
          $img read "$SCRIPT_PATH/imgs/$card(image)"
          .board.discard.c create image [expr 170 * $nb_cards] 0 -image $img -tags img_dcards$nb_cards -anchor nw
          if { ($MODE_SEL == 5) && ([GUI_IsPlaying] == 1) } {
            .board.discard.c bind img_dcards$nb_cards <ButtonRelease-1> "ACTION_BuildWonderAndRebirth $j $i"
            .board.discard.c bind img_dcards$nb_cards <Leave> "DISCARD_HighlightCard $nb_cards 0"
            .board.discard.c bind img_dcards$nb_cards <Enter> "DISCARD_HighlightCard $nb_cards 1"
          } else {
            .board.discard.c bind img_dcards$nb_cards <ButtonRelease-1> ""
            .board.discard.c bind img_dcards$nb_cards <Enter> ""
          }
          # Purple rectangle
          set round [lindex $game_state(action_wcard) 0]
          set index [lindex $game_state(action_wcard) 1]
          if { $index >= 0 } {
            array set discarded_card [lindex $game_state(cards$round) $index]
            set name $discarded_card(name)
          } else {
            set name ""
          }
          if { $name == $card(name) } {
            set coords [.board.discard.c coords img_dcards$nb_cards]
            set x1 [expr [lindex $coords 0] + 1]
            set y1 [expr [lindex $coords 1] + 1]
            set x2 [expr 170 + $x1 - 3]
            set y2 [expr 260 + $y1 - 3]
            .board.discard.c create rectangle $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_last_discard
          }
          incr nb_cards
        }
      }
    }
    .board.discard.c configure -scrollregion "0 0 [expr 170 * $nb_cards] 0"
  }
}

# Close window
proc DISCARD_CloseWindow {} {
  variable MODE_SEL

  if { $MODE_SEL == 5 } { set MODE_SEL 0 }
  BOARD_ManageInfoMessage
  if { [winfo exists .board.discard] } { destroy .board.discard }
}

# Card highlighting
proc DISCARD_HighlightCard {index value} {
  variable DISCARD_INDEX
  variable MODE_SEL

  if { $value    == 0 } { set DISCARD_INDEX -1 }
  if { $MODE_SEL != 5 } { return }
  if { $value    == 1 } { set DISCARD_INDEX $index }
}


