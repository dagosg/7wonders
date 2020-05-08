#!/usr/bin/tclsh

# Board window
proc WONDERS_DisplayWonders {} {
  variable game_state

  if { ($game_state(player_turn) < 1) || ($game_state(player_turn) > 8) } { 
    WONDERS_CloseWonders
  } elseif { ![winfo exists .board.wonders] } {
    toplevel .board.wonders -bd 0
    for { set i 0 } { $i < 4 } { incr i } {
      frame .board.wonders.f$i -borderwidth 0 -relief sunken
      canvas .board.wonders.f$i.c$i -width 299 -height 194 -borderwidth 1
      pack .board.wonders.f$i.c$i
    }
    catch {wm attributes .board.wonders -type tooltip}
    catch {wm attributes .board.wonders -toolwindow 1}
    wm protocol .board.wonders WM_DELETE_WINDOW "GUI_Close .board.wonders ; catch {wm attributes .board.wonders -type tooltip} ; catch {wm attributes .board.wonders -toolwindow 1} ; catch {wm attributes .board.wonders -topmost 1}"
    wm attributes .board.wonders -topmost 1
    wm withdraw .board.wonders
    update
    if { [winfo exists .board.wonders] } {
      wm title .board.wonders "7 Wonders Duel - Sélection des merveilles"
      wm transient .board.wonders .
      wm deiconify .board.wonders
      grid .board.wonders.f0 .board.wonders.f1 -sticky nsew
      grid .board.wonders.f2 .board.wonders.f3 -sticky nsew
      TOOLS_SetShortcuts .board.wonders
      update
      after 100 "catch { wm geometry .board.wonders +[BOARD_Scale 300]+[BOARD_Scale 300] }"
      catch { wm resizable .board.wonders 0 0 }
    }
  }
  WONDERS_UpdateWonders
}

# Update board window
proc WONDERS_UpdateWonders {} {
  variable game_state
  variable SCRIPT_PATH
  variable GUI_UPDATED

  if { ($game_state(player_turn) < 1) || ($game_state(player_turn) > 8) } { 
    WONDERS_CloseWonders
  } elseif { ([winfo exists .board.wonders]) && ($GUI_UPDATED < 0) } {
    # Manage wonder elements
    for { set i 0 } { $i < 4 } { incr i } {
      .board.wonders.f$i.c$i delete wonder$i 
      set j $i
      if { $game_state(player_turn) > 4 } { set j [expr $i + 4] }
      array set wonder [lindex $game_state(wonders) $j]
      if { $wonder(owner) == "" } {
        set img [image create photo]
        $img read "$SCRIPT_PATH/imgs/$wonder(image)"
        .board.wonders.f$i.c$i create image 0 0 -image $img -tags wonder$i -anchor nw
      }
      if { ($wonder(owner) == "") && ([GUI_IsPlaying] == 1) } {
        bind .board.wonders.f$i.c$i <ButtonRelease-1> "WONDERS_SelectWonder $i"
        bind .board.wonders.f$i.c$i <Leave> ".board.wonders.f$i.c$i configure -borderwidth 1 ; .board.wonders.f$i configure -borderwidth 0"
        bind .board.wonders.f$i.c$i <Enter> ".board.wonders.f$i.c$i configure -borderwidth 0 ; .board.wonders.f$i configure -borderwidth 1"
      } else {
        bind .board.wonders.f$i.c$i <ButtonRelease-1> ""
        bind .board.wonders.f$i.c$i <Enter> ""
        .board.wonders.f$i.c$i configure -borderwidth 1
        .board.wonders.f$i configure -borderwidth 0
      }
    }

    # Focus
    focus .board.wonders
  }
}

# Close window
proc WONDERS_CloseWonders {} {
  if { [winfo exists .board.wonders] } { destroy .board.wonders }
}

# Wonder selection
proc WONDERS_SelectWonder {num} {
  variable tcp_socket
  variable game_state

  set game_state(play) ""
  set GUI_UPDATED -1
  WONDERS_DisplayWonders
  catch { puts $tcp_socket "SelectWonder $num" }
}


