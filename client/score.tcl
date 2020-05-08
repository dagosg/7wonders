#!/usr/bin/tclsh

# Display scores
proc SCORE_DisplayScore {} {
  variable game_state

  if { $game_state(round) < 4 } {
    SCORE_CloseWindow
  } elseif { ![winfo exists .board.score] } {
    toplevel .board.score -bd 0
    canvas .board.score.c -height 374 -width 260
    pack .board.score.c -expand 1 -side top -fill both
    catch {wm attributes .board.score -type tooltip}
    catch {wm attributes .board.score -toolwindow 1}
    wm protocol .board.score WM_DELETE_WINDOW "BOARD_New .board.score"
    wm attributes .board.score -topmost 1
    wm withdraw .board.score
    update
    if { [winfo exists .board.score] } {
      wm title .board.score "7 Wonders Duel - Fin de partie"
      wm transient .board.score .
      wm deiconify .board.score
      TOOLS_SetShortcuts .board.score
      update
      after 100 "catch { wm geometry .board.score +[BOARD_Scale 250]+[BOARD_Scale 250] }"
      catch { wm resizable .board.score 0 0 }
    }
  }
  SCORE_UpdateScore
}

# Update scores
variable RESET
set RESET 1
proc SCORE_UpdateScore {} {
  variable SCRIPT_PATH
  variable game_state
  variable GUI_UPDATED
  variable MODE_SEL
  variable RESET

  # Manage card elements
  if { $game_state(round) < 4 } {
    SCORE_CloseWindow
    set RESET 1
  } elseif { ([winfo exists .board.score]) && ($GUI_UPDATED < 0) } {
    .board.score.c delete img_score txt_score winner
    set img_score [image create photo]
    $img_score read "$SCRIPT_PATH/imgs/score.png"
    .board.score.c create image 2 2 -image $img_score -tags img_score -anchor nw
    # Fill score
    set total1 [TOOLS_NbPV "$game_state(player_first)" ]
    set total2 [TOOLS_NbPV "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  0 [string range "$game_state(player_first)"  0 8]
    SCORE_DisplayTxt "$game_state(player_second)" 0 [string range "$game_state(player_second)" 0 8]
    SCORE_DisplayTxt "$game_state(player_first)"  1 [TOOLS_NbPVByColor "blue"   "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 1 [TOOLS_NbPVByColor "blue"   "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  2 [TOOLS_NbPVByColor "green"  "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 2 [TOOLS_NbPVByColor "green"  "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  3 [TOOLS_NbPVByColor "yellow" "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 3 [TOOLS_NbPVByColor "yellow" "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  4 [TOOLS_NbPVByColor "purple" "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 4 [TOOLS_NbPVByColor "purple" "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  5 [TOOLS_NbPVWonderBuilt      "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 5 [TOOLS_NbPVWonderBuilt      "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  6 [TOOLS_NbPVJetons           "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 6 [TOOLS_NbPVJetons           "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  7 [TOOLS_NbGoldBonus          "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 7 [TOOLS_NbGoldBonus          "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  8 [TOOLS_NbWarBonus           "$game_state(player_first)" ]
    SCORE_DisplayTxt "$game_state(player_second)" 8 [TOOLS_NbWarBonus           "$game_state(player_second)"]
    SCORE_DisplayTxt "$game_state(player_first)"  9 $total1
    SCORE_DisplayTxt "$game_state(player_second)" 9 $total2
    if { $game_state(win_war)     == "player_first"  } { SCORE_DisplayTxt "$game_state(player_first)"  10 X }
    if { $game_state(win_war)     == "player_second" } { SCORE_DisplayTxt "$game_state(player_second)" 10 X }
    if { $game_state(win_science) == "player_first"  } { SCORE_DisplayTxt "$game_state(player_first)"  11 X }
    if { $game_state(win_science) == "player_second" } { SCORE_DisplayTxt "$game_state(player_second)" 11 X }
    .board.score.c itemconfigure txt_score -font "Arial 14 bold"

    # Set winner
    set winner ""
    if { ($game_state(win_war)     == "player_first")  ||
         ($game_state(win_science) == "player_first")  } { set winner "player_first" }
    if { ($game_state(win_war)     == "player_second") ||
         ($game_state(win_science) == "player_second") } { set winner "player_second" }
    if { $winner == "" } {
      if { $total1 > $total2 } {
        set winner "player_first"
      } elseif { $total2 > $total1 } {
        set winner "player_second"
      } else {
        set nb1 [TOOLS_NbPVByColor "blue" "$game_state(player_first)" ]
        set nb2 [TOOLS_NbPVByColor "blue" "$game_state(player_second)"]
        if { $nb1 > $nb2 } {
          set winner "player_first"
        } elseif { $nb2 > $nb1 } {
          set winner "player_second"
        } else {
          # Equal score
        }
      }
    }

    # Display a rectangle on the winner
    if { $winner == "player_first" } {
      .board.score.c create rectangle  59 5 156 32 -outline "goldenrod2" -width 3 -tags winner
      if { $RESET == 1 } {
        CHAT_DisplayMessage "$game_state(player_first) a remporté la partie!" "black"
      }
    }
    if { $winner == "player_second" } {
      .board.score.c create rectangle 161 5 257 32 -outline "goldenrod2" -width 3 -tags winner
      if { $RESET == 1 } {
        CHAT_DisplayMessage "$game_state(player_second) a remporté la partie!" "black"
      }
    }
    if { $winner == "" } {
      if { $RESET == 1 } {
        CHAT_DisplayMessage "Vous avez fait égalité!" "black"
      }
    }
    set RESET 0

    # Focus
    focus .board.score
  }
}

# Close window
proc SCORE_CloseWindow {} {
  if { [winfo exists .board.score] } { destroy .board.score }
}

# Dsplay a text
proc SCORE_DisplayTxt {name line txt} {
  variable game_state

  # Get player
  if { $txt == 0 } { set txt "-" }
  set x 0
  set offset 0
  if { "$name" == "$game_state(player_second)" } { set x 1 }
  if { $line == 0  } { set offset -2 }
  if { $line == 10 } { set offset  3 }
  if { $line == 11 } { set offset  7 }
  .board.score.c create text [expr ($x * 101) + 108] [expr ($line * 30) + 10 + $offset] -text $txt -tags txt_score -anchor n
}

