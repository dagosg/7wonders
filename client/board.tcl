#!/usr/bin/tclsh

# Client version
variable game_state
set game_state(version_client) "c"

# Initial values
variable CARD_INDEX
variable WONDER_INDEX
variable JETON_INDEX
variable BROWN_INDEX
variable GRAY_INDEX
variable DISCARD_INDEX
variable JETON3_INDEX
variable MODE_SEL
variable DISCARD
variable ZOOM_IN
variable ZOOM_OUT
set CARD_INDEX    -1
set WONDER_INDEX  -1
set JETON_INDEX   -1
set BROWN_INDEX   -1
set GRAY_INDEX    -1
set DISCARD_INDEX -1
set JETON3_INDEX  -1
set MODE_SEL      0
set DISCARD       0
if { ![info exists ZOOM_IN ] } { set ZOOM_IN  1 }
if { ![info exists ZOOM_OUT] } { set ZOOM_OUT 1 }

# Test
proc BOARD_Test {} {}

# Exit
proc BOARD_Exit {} {
  set forever 0
  after 300 "destroy ."
}

# New game
proc BOARD_New {window} {
  variable tcp_socket

  focus $window
  set answer [tk_messageBox -message "Voulez-vous commencer une nouvelle partie?" -icon question -parent $window -type yesno -title "Nouvelle partie"]
  if { $answer == "yes" } {
    catch { puts $tcp_socket "NewGame" }
  }
}

# Load game
proc BOARD_Load {} {
  variable tcp_socket

  catch { puts $tcp_socket "LoadGame" }
}

# Save game
proc BOARD_Save {} {
  variable tcp_socket

  catch { puts $tcp_socket "SaveGame" }
}

# Back a turn
proc BOARD_PlayBack {} {
  variable tcp_socket

  catch { puts $tcp_socket "PlayBack" }
}

# Next a turn
proc BOARD_PlayNext {} {
  variable tcp_socket

  catch { puts $tcp_socket "PlayNext" }
}

# Kill server
proc BOARD_KillServer {} {
  variable tcp_socket

  catch { puts $tcp_socket "KillYou" }
}

# Zoom
proc BOARD_ZoomImage {image_src} {
  variable ZOOM_IN
  variable ZOOM_OUT

  if { $ZOOM_IN == $ZOOM_OUT } { return $image_src }
  set img_tmp1 [image create photo]
  set img_tmp2 [image create photo]
  $img_tmp1 copy $image_src -shrink -zoom      $ZOOM_IN  $ZOOM_IN
  $img_tmp2 copy $img_tmp1  -shrink -subsample $ZOOM_OUT $ZOOM_OUT
  return $img_tmp2
}

# Scale for zoom
proc BOARD_Scale {value} {
  variable ZOOM_IN
  variable ZOOM_OUT

  return [expr int(($value.0 * $ZOOM_IN.0) / $ZOOM_OUT.0)]
}

# Invert zoom
proc BOARD_ChangeZoom {} {
  variable ZOOM_IN
  variable ZOOM_OUT
  variable GUI_UPDATED

  if { $ZOOM_IN == 1 } {
    set ZOOM_IN  3
    set ZOOM_OUT 4
  } else {
    set ZOOM_IN  1
    set ZOOM_OUT 1
  }
  CHAT_SetSize
  set GUI_UPDATED -1
  BOARD_DisplayBoard
}

# Refresh the game
proc BOARD_RefreshGame {} {
  variable tcp_socket

  if { [catch { puts $tcp_socket "RefreshGame" ; flush $tcp_socket } err] } {
    catch { unset tcp_socket }
    GUI_ConnectToServer
  }
}

# Board window
proc BOARD_DisplayBoard {} {
  variable game_state
  variable GUI_UPDATED

  # First check version
  if { $game_state(version_server_major) != $game_state(version_server_compatibility) } {
    tk_messageBox -message "La version du serveur (v$game_state(version_server_major).$game_state(version_server_minor)) est incompatible avec la version du client." -type ok -title "Erreur de version"
    set forever 0
    destroy .
  }

  if { ![winfo exists .board] } {
    toplevel .board
    wm attributes .board -fullscreen 1
    wm protocol .board WM_DELETE_WINDOW "catch { focus .board.chat.fm.t }"
    wm withdraw .board
    update
    if { [winfo exists .board] } {
      wm title .board "7 Wonders Duel - Plateau de jeu - v$game_state(version_server_major).$game_state(version_server_minor)$game_state(version_client)"
      wm deiconify .board
      canvas .board.c
      pack .board.c    -expand 1 -fill both -side top
      TOOLS_SetShortcuts .board
    }
  }
  if { $GUI_UPDATED == -2 } { JETONS_CloseWindow }
  if { $game_state(action_discard) == -2 } {
    # No mouvement (load/refresh)
    if { ([winfo exists .board]) && ($GUI_UPDATED < 0) } {
      BOARD_UpdateBoard
    }
  } else {
    BOARD_AllMvt
  }
}

# Mouvement before update board
variable MOVE_STEP
set MOVE_STEP 0
proc BOARD_AllMvt {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable game_state
  variable GUI_UPDATED

  # Move card to wonder
  if { ([winfo exists .board]) && ($GUI_UPDATED < 0) } {
    # If no movement and internal refresh
    if { ($MOVE_STEP == 0) && ($GUI_UPDATED == -1) } {
      BOARD_UpdateBoard
      return
    }
    # Get card
    set j     [lindex $game_state(action_wcard) 0]
    set index [lindex $game_state(action_wcard) 1]
    if { $j == 0 } {
      BOARD_UpdateBoard
      return
    }
    if { $index >= 0 } {
      array set card [lindex $game_state(cards$j) $index]
    }
    if { ($game_state(action_wonder) >= 0) && ($MOVE_STEP == 0) } {
      # Source position
      set coords [.board.c coords img_card[set j]_$index]
      set MOVE_STARTX [lindex $coords 0]
      set MOVE_STARTY [lindex $coords 1]
      # Destination position
      set coords [.board.c coords img_wonder$game_state(action_wonder)]
      set MOVE_ENDX [expr [lindex $coords 0] + [BOARD_Scale 25]]
      set MOVE_ENDY [expr [lindex $coords 1] - [BOARD_Scale 30]]
      # Move the card
      set MOVE_STEP 25
      BOARD_MvtCard
    } elseif { ($index >= 0) && ($MOVE_STEP == 0) && ($card(owner) != "") } {
      # Source position
      set coords [.board.c coords img_card[set j]_$index]
      set MOVE_STARTX [lindex $coords 0]
      set MOVE_STARTY [lindex $coords 1]
      # Destination position
      if { $card(owner) == "discard" } {
        set MOVE_ENDX [BOARD_Scale 550]
        set MOVE_ENDY [BOARD_Scale 100]
      } else {
        set MOVE_ENDY [BOARD_Scale 400]
        if { ($game_state($card(owner)) == $PLAYER_NAME) ||
             (($card(owner) == "player_first") && ($PLAYER_OBS == 1)) } {
          set MOVE_ENDX [BOARD_Scale 50]
        } else {
          set MOVE_ENDX [BOARD_Scale 1050]
        }
      }
      # Move the card
      set MOVE_STEP 25
      BOARD_MvtCard
    } elseif { $MOVE_STEP == 0 } {
      BOARD_MvtWarrior
    }
  }
}

# Move it
proc BOARD_MvtCard {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable game_state

  set MOVE_STEP [expr $MOVE_STEP - 1]
  catch {
    set POSX [expr (($MOVE_ENDX - $MOVE_STARTX) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTX]
    set POSY [expr (($MOVE_ENDY - $MOVE_STARTY) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTY]
  } else {
    set MOVE_STEP 0
    BOARD_UpdateBoard
    return
  }
  set j     [lindex $game_state(action_wcard) 0]
  set index [lindex $game_state(action_wcard) 1]
  catch { .board.c coords img_card[set j]_$index "$POSX $POSY" }
  if { $MOVE_STEP == 0 } {
    if { $game_state(action_jeton) >= 0 } {
      array set jeton [lindex $game_state(jetons) $game_state(action_jeton)]
      # Source position
      set coords [.board.c coords img_jeton$game_state(action_jeton)]
      set MOVE_STARTX [lindex $coords 0]
      set MOVE_STARTY [lindex $coords 1]
      # Destination position
      set MOVE_ENDY [BOARD_Scale 5]
      if { ($game_state($jeton(owner)) == $PLAYER_NAME) ||
           (($PLAYER_OBS == 1) && ($jeton(owner) == "player_first")) } {
        set MOVE_ENDX [BOARD_Scale 50]
      } else {
        set MOVE_ENDX [BOARD_Scale 1080]
      }
      # Avoid mouvement if already in position
      if { ($MOVE_STARTX > [BOARD_Scale 300]) && ($MOVE_STARTX < [BOARD_Scale 900]) } {
        # Manage jeton mouvement
        set MOVE_STEP 25
        BOARD_MvtJeton
      } else {
        BOARD_UpdateBoard
      }
    } elseif { ($game_state(action_wonder)  >= 0) &&
               ($game_state(action_discard) >= 0) && 
               ($game_state(action_discard_owner) != "") } {
      # Source position
      if { ($game_state($game_state(action_discard_owner)) == $PLAYER_NAME) ||
           (($PLAYER_OBS == 1) && ($game_state(action_discard_owner) == "player_first")) } {
        set coords [.board.c coords img_cards_p1_$game_state(action_discard)]
      } else {
        set coords [.board.c coords img_cards_p2_$game_state(action_discard)]
      }
      set MOVE_STARTX [lindex $coords 0]
      set MOVE_STARTY [lindex $coords 1]
      # Destination position
      set MOVE_ENDX [BOARD_Scale 550]
      set MOVE_ENDY [BOARD_Scale 100]
      # Manage card mouvement
      set MOVE_STEP 25
      BOARD_MvtDiscard
    } else {
      BOARD_MvtWarrior
    }
  } else {
    catch { focus .board.chat.fm.t }
    after 40 "BOARD_MvtCard"
  }
}

# Move it
proc BOARD_MvtJeton {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable game_state

  set MOVE_STEP [expr $MOVE_STEP - 1]
  catch {
    set POSX [expr (($MOVE_ENDX - $MOVE_STARTX) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTX]
    set POSY [expr (($MOVE_ENDY - $MOVE_STARTY) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTY]
  } else {
    set MOVE_STEP 0
    BOARD_UpdateBoard
    return
  }
  set j     [lindex $game_state(action_wcard) 0]
  set index [lindex $game_state(action_wcard) 1]
  catch { .board.c coords img_jeton$game_state(action_jeton) "$POSX $POSY" }
  if { $MOVE_STEP == 0 } {
    BOARD_UpdateBoard
  } else {
    catch { focus .board.chat.fm.t }
    after 40 "BOARD_MvtJeton"
  }
}

# Move it
proc BOARD_MvtDiscard {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable game_state

  set MOVE_STEP [expr $MOVE_STEP - 1]
  catch {
    set POSX [expr (($MOVE_ENDX - $MOVE_STARTX) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTX]
    set POSY [expr (($MOVE_ENDY - $MOVE_STARTY) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTY]
  } else {
    set MOVE_STEP 0
    BOARD_UpdateBoard
    return
  }

  # Find card
  if { ($game_state($game_state(action_discard_owner)) == $PLAYER_NAME) ||
       (($PLAYER_OBS == 1) && ($game_state(action_discard_owner) == "player_first")) } {
    set img "img_cards_p1_$game_state(action_discard)"
  } else {
    set img "img_cards_p2_$game_state(action_discard)"
  }

  # Move
  catch { .board.c coords $img "$POSX $POSY" }
  if { $MOVE_STEP == 0 } {
    BOARD_UpdateBoard
  } else {
    catch { focus .board.chat.fm.t }
    after 40 "BOARD_MvtDiscard"
  }
}

# Mouvement of warrior
proc BOARD_MvtWarrior {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable game_state

  # Move warrior
  if { ($game_state(action_warrior) == 1) && ($MOVE_STEP == 0) } {
    # Source position
    set coords [.board.c coords img_warrior]
    set MOVE_STARTX [lindex $coords 0]
    set MOVE_STARTY [lindex $coords 1]
    # Destination position
    set pos $game_state(warrior)
    if { ($PLAYER_NAME == $game_state(player_first)) || ($PLAYER_OBS == 1) } {
      set MOVE_ENDX [BOARD_Scale [expr int(583 + ($pos * 38.5))]]
    } else {
      set MOVE_ENDX [BOARD_Scale [expr int(583 + ($pos * -38.5))]]
    }
    set MOVE_ENDY [BOARD_Scale 81]
    # Move the warrior
    set MOVE_STEP 25
    BOARD_MvtWarriorPerform
  } elseif { $MOVE_STEP == 0 } {
    BOARD_UpdateBoard
  }
}

# Move it
proc BOARD_MvtWarriorPerform {} {
  variable MOVE_STEP
  variable MOVE_STARTX
  variable MOVE_STARTY
  variable MOVE_ENDX
  variable MOVE_ENDY
  variable game_state

  set MOVE_STEP [expr $MOVE_STEP - 1]
  catch {
    set POSX [expr (($MOVE_ENDX - $MOVE_STARTX) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTX]
    set POSY [expr (($MOVE_ENDY - $MOVE_STARTY) * ((25.0 - $MOVE_STEP) / 25.0)) + $MOVE_STARTY]
  } else {
    set MOVE_STEP 0
    BOARD_UpdateBoard
    return
  }

  # Move
  catch { .board.c coords img_warrior "$POSX $POSY" }
  if { $MOVE_STEP == 0 } {
    BOARD_UpdateBoard
  } else {
    catch { focus .board.chat.fm.t }
    after 40 "BOARD_MvtWarriorPerform"
  }
}

# Board window
proc BOARD_UpdateBoard {} {
  variable SCRIPT_PATH
  variable game_state
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable CARDS_P1
  variable CARDS_P2
  variable MODE_SEL
  variable ZOOM_IN
  variable ZOOM_OUT

  # Manage board elements
  if { [winfo exists .board] } {
    # No selection
    set CARD_INDEX    -1
    set WONDER_INDEX  -1
    set JETON_INDEX   -1
    set BROWN_INDEX   -1
    set GRAY_INDEX    -1
    set DISCARD_INDEX -1
    set JETON3_INDEX  -1

    # Update players cards and funds
    TOOLS_FillPlayersCards $PLAYER_NAME $PLAYER_OBS
    TOOLS_FillPlayersFunds $PLAYER_NAME $PLAYER_OBS

    # Load board image
    .board.c delete img_background img_board img_discard img_warrior img_malus_l0 img_malus_l1 img_malus_r0 img_malus_r1 txt_built txt_info
    .board.c delete img_gold_p1 img_gold_p2 img_gold_t1 img_gold_t2 img_pv_p1 img_pv_p2 img_pv_t1 img_pv_t2 txt_names img_actions img_rect2_wonder
    .board.c delete img_rect_wonder
    .board.c delete img_oval_jeton
    .board.c delete img_rect_card
    .board.c delete img_rect_brown
    .board.c delete img_rect_gray
    .board.c delete img_oval_discard
    for { set i 0 } { $i < 8  } { incr i } { .board.c delete img_wonder$i }
    for { set i 0 } { $i < 6  } { incr i } { .board.c delete img_jeton$i }
    for { set i 0 } { $i < 20 } { incr i } { .board.c delete img_card1_$i }
    for { set i 0 } { $i < 20 } { incr i } { .board.c delete img_card2_$i }
    for { set i 0 } { $i < 20 } { incr i } { .board.c delete img_card3_$i }
    for { set i 0 } { $i < 60 } { incr i } { .board.c delete img_cards_p1_$i }
    for { set i 0 } { $i < 60 } { incr i } { .board.c delete img_cards_p2_$i }

    # Create background and board images
    set img_board [image create photo]
    $img_board read "$SCRIPT_PATH/imgs/board_empty.png"
    set img_board [BOARD_ZoomImage $img_board]
    set img_background [image create photo]
    $img_background read "$SCRIPT_PATH/imgs/background.png"
    set img_background [BOARD_ZoomImage $img_background]
    .board.c create image 0   0 -image $img_background -tags img_background -anchor nw
    .board.c create image 200 0 -image $img_board      -tags img_board      -anchor nw

    # Create discard area
    set img_discard [image create photo]
    $img_discard read "$SCRIPT_PATH/imgs/defausse.png"
    set img_discard [BOARD_ZoomImage $img_discard]
    .board.c create image 583 180 -image $img_discard -tags img_discard -anchor nw
    .board.c bind img_discard <ButtonRelease-1> "DISCARD_DisplayDiscardCards"
    .board.c bind img_discard <Leave> "BOARD_HighlightDiscard 0"
    .board.c bind img_discard <Enter> "BOARD_HighlightDiscard 1"
    # Must select the discard arear
    if { $game_state(action_discard) >= 0 } {
      set coords [.board.c coords img_discard]
      set x1 [lindex $coords 0]
      set y1 [lindex $coords 1]
      set x2 [expr 34 + $x1]
      set y2 [expr 38 + $y1]
      .board.c create oval $x1 [expr $y1 + 2] $x2 [expr $y2 - 2] -outline "purple3" -width 4 -tags img_actions
    }

    # Create information area
    .board.c create text 600 848 -tags txt_info -anchor n -fill "DarkBlue"
    .board.c itemconfigure txt_info -font "Arial 10 bold"

    # Display name, gold and PV of each player
    set img_gold [image create photo]
    $img_gold read "$SCRIPT_PATH/imgs/gold.png"
    set img_gold [BOARD_ZoomImage $img_gold]
    set img_pv [image create photo]
    $img_pv read "$SCRIPT_PATH/imgs/pv.png"
    set img_pv [BOARD_ZoomImage $img_pv]
    set pv1 [TOOLS_NbPV $game_state(player_first) ]
    set pv2 [TOOLS_NbPV $game_state(player_second)]
    if { ($PLAYER_NAME == $game_state(player_first)) || ($PLAYER_OBS == 1) } {
      .board.c create text  160 75 -text "$game_state(player_first)" -tags txt_names -anchor w
      .board.c create image 160 15 -image $img_gold -tags img_gold_p1 -anchor nw
      .board.c create text  220 37 -text "$game_state(gold_player_first)"  -tags img_gold_t1 -anchor w
      .board.c create image 265 15 -image $img_pv -tags img_pv_p1 -anchor nw
      .board.c create text  325 37 -text "$pv1" -tags img_pv_t1 -anchor w

      .board.c create text  825 75 -text "$game_state(player_second)" -tags txt_names -anchor w
      .board.c create image 825 15 -image $img_gold -tags img_gold_p2 -anchor nw
      .board.c create text  885 37 -text "$game_state(gold_player_second)" -tags img_gold_t2 -anchor w
      .board.c create image 930 15 -image $img_pv -tags img_pv_p2 -anchor nw
      .board.c create text  990 37 -text "$pv2" -tags img_pv_t2 -anchor w
    } else {
      .board.c create text  160 75 -text "$game_state(player_second)" -tags txt_names -anchor w
      .board.c create image 160 15 -image $img_gold -tags img_gold_p2 -anchor nw
      .board.c create text  220 37 -text "$game_state(gold_player_second)" -tags img_gold_t2 -anchor w
      .board.c create image 265 15 -image $img_pv -tags img_pv_p2 -anchor nw
      .board.c create text  325 37 -text "$pv2" -tags img_pv_t2 -anchor w

      .board.c create text  825 75 -text "$game_state(player_first)" -tags txt_names -anchor w
      .board.c create image 825 15 -image $img_gold -tags img_gold_p1 -anchor nw
      .board.c create text  885 37 -text "$game_state(gold_player_first)"  -tags img_gold_t1 -anchor w
      .board.c create image 930 15 -image $img_pv -tags img_pv_p1 -anchor nw
      .board.c create text  990 37 -text "$pv1" -tags img_pv_t1 -anchor w
    }
    set font [.board.c itemcget img_gold_t1 -font]
    .board.c itemconfigure img_gold_t1 -font "$font 18 bold"
    .board.c itemconfigure img_gold_t2 -font "$font 18 bold"
    .board.c itemconfigure img_pv_t1 -font "$font 18 bold"
    .board.c itemconfigure img_pv_t2 -font "$font 18 bold"
    .board.c itemconfigure txt_names -font "$font 12 bold"

    # Display selected wonders
    set num_me 0
    set num_ot 0
    for { set i 0 } { $i < 8 } { incr i } {
      if { [llength $game_state(wonders)] > $i } {
        array set wonder [lindex $game_state(wonders) $i]
        if { $wonder(owner) != "" } {
          if { ($game_state($wonder(owner)) == $PLAYER_NAME) ||
               (($PLAYER_OBS == 1) && ($wonder(owner) == "player_first")) ||
               (($game_state(player_first) == "") && ($game_state(player_second) == "") && ($wonder(owner) == "player_first")) } {
            set img_wonder [image create photo]
            set idx_last [TOOLS_GetLastWonder]
            if { $idx_last == $i } {
              $img_wonder read "$SCRIPT_PATH/imgs/wonder_mini_back.png"
            } else {
              $img_wonder read "$SCRIPT_PATH/imgs/[string replace $wonder(image) 6 6 _mini_]"
            }
            set img_wonder [BOARD_ZoomImage $img_wonder]
            .board.c create image [expr ($num_me * 149)] 746 -image $img_wonder -tags img_wonder$i -anchor nw
            if { [TOOLS_IsWonderBuilt $i] == 1 } {
              .board.c create text [expr ($num_me * 149) + 75] 760 -text "CONSTRUIT" -tags txt_built -anchor n -fill "light cyan"
              .board.c itemconfigure txt_built -font "Arial 14 bold"
            }
            if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsWonderSelectable $PLAYER_NAME $i] == 1) } {
              .board.c bind img_wonder$i <ButtonRelease-1> "ACTION_DisplayActionWonder $i"
              .board.c bind img_wonder$i <Leave> "BOARD_HighlightWonder $i 0"
              .board.c bind img_wonder$i <Enter> "BOARD_HighlightWonder $i 1"
            } else {
              .board.c bind img_wonder$i <ButtonRelease-1> ""
              .board.c bind img_wonder$i <Enter> ""
            }
            # Must select a wonder (obs)
            if { $game_state(action_wonder) == $i } {
              set coords [.board.c coords img_wonder$i]
              set x1 [expr [lindex $coords 0] + 2]
              set y1 [expr [lindex $coords 1] + 2]
              set x2 [expr 149 + $x1 - 4]
              set y2 [expr  98 + $y1 - 4]
              .board.c create rectangle $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_actions
            }
            incr num_me
          } else {
            set img_wonder [image create photo]
            set idx_last [TOOLS_GetLastWonder]
            if { $idx_last == $i } {
              $img_wonder read "$SCRIPT_PATH/imgs/wonder_mini_back.png"
            } else {
              $img_wonder read "$SCRIPT_PATH/imgs/[string replace $wonder(image) 6 6 _mini_]"
            }
            set img_wonder [BOARD_ZoomImage $img_wonder]
            .board.c create image [expr 603 + ($num_ot * 149)] 746 -image $img_wonder -tags img_wonder$i -anchor nw
            if { [TOOLS_IsWonderBuilt $i] == 1 } {
              .board.c create text [expr 603 + ($num_ot * 149) + 75] 760 -text "CONSTRUIT" -tags txt_built -anchor n -fill "light cyan"
              .board.c itemconfigure txt_built -font "Arial 14 bold"
            }
            # Must select a wonder
            if { $game_state(action_wonder) == $i } {
              set coords [.board.c coords img_wonder$i]
              set x1 [expr [lindex $coords 0] + 2]
              set y1 [expr [lindex $coords 1] + 2]
              set x2 [expr 149 + $x1 - 4]
              set y2 [expr  98 + $y1 - 4]
              .board.c create rectangle $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_actions
            }
            incr num_ot
          }
        }
      }
    }
    if { $game_state(player_turn) > 8 } {
      .board.c create rectangle 2   745 598  845 -outline "brown" -width 3 -tags img_rect2_wonder
      .board.c create rectangle 603 745 1199 845 -outline "brown" -width 3 -tags img_rect2_wonder
    }

    # Display random jetons
    set num_me 0
    set num_ot 0
    for { set i 0 } { $i < 6 } { incr i } {
      if { [llength $game_state(jetons)] > $i } {
        array set jeton [lindex $game_state(jetons) $i]
        set img_jeton [image create photo]
        $img_jeton read "$SCRIPT_PATH/imgs/$jeton(image)"
        set img_jeton [BOARD_ZoomImage $img_jeton]
        if { $jeton(owner) == "" } {
          .board.c create image [expr 403 + ($i * 80.5)] 11 -image $img_jeton -tags img_jeton$i -anchor nw
          if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsJetonSelectable $i] == 1) } {
            .board.c bind img_jeton$i <ButtonRelease-1> "ACTION_TakeJeton $i"
            .board.c bind img_jeton$i <Leave> "BOARD_HighlightJeton $i 0"
            .board.c bind img_jeton$i <Enter> "BOARD_HighlightJeton $i 1"
          } else {
            .board.c bind img_jeton$i <ButtonRelease-1> ""
            .board.c bind img_jeton$i <Leave> "BOARD_InfoJeton $i 0"
            .board.c bind img_jeton$i <Enter> "BOARD_InfoJeton $i 1"
          }
        } elseif { ($game_state($jeton(owner)) == $PLAYER_NAME) ||
                   (($PLAYER_OBS == 1) && ($jeton(owner) == "player_first")) ||
                   (($game_state(player_first) == "") && ($game_state(player_second) == "") && ($jeton(owner) == "player_first")) } {
          .board.c create image [expr 4 + ($num_me * 33)] 5 -image $img_jeton -tags img_jeton$i -anchor nw
          incr num_me
        } else {
          .board.c create image [expr 1126 - (3 * 33) + ($num_ot * 33)] 5 -image $img_jeton -tags img_jeton$i -anchor nw      
          incr num_ot
        }
        # Must select a jeton    
        if { $game_state(action_jeton) == $i } {
          set coords [.board.c coords img_jeton$i]
          set x1 [expr [lindex $coords 0] + 1]
          set y1 [expr [lindex $coords 1] + 1]
          set x2 [expr 67 + $x1 - 3]
          set y2 [expr 67 + $y1 - 3]
          .board.c create oval $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_actions
        }
      }
    }

    # Display my malus (if I play) or first player malus
    set malus_l {1 1}
    set malus_r {1 1}
    if { $PLAYER_NAME == $game_state(player_first)  } { set malus_l $game_state(malus_player_first)  }
    if { $PLAYER_NAME == $game_state(player_second) } { set malus_l $game_state(malus_player_second) }
    if { $PLAYER_OBS  == 1                          } { set malus_l $game_state(malus_player_first)  }
    if { $PLAYER_NAME == $game_state(player_first)  } { set malus_r $game_state(malus_player_second) }
    if { $PLAYER_NAME == $game_state(player_second) } { set malus_r $game_state(malus_player_first)  }
    if { $PLAYER_OBS  == 1                          } { set malus_r $game_state(malus_player_second) }
    if { [lindex $malus_l 0] == 1 } {
      set img_malus_l0 [image create photo]
      $img_malus_l0 read "$SCRIPT_PATH/imgs/malus2.png"
      set img_malus_l0 [BOARD_ZoomImage $img_malus_l0]
      .board.c create image 406 170 -image $img_malus_l0 -tags img_malus_l0 -anchor nw
    }
    if { [lindex $malus_l 1] == 1 } {
      set img_malus_l1 [image create photo]
      $img_malus_l1 read "$SCRIPT_PATH/imgs/malus5.png"
      set img_malus_l1 [BOARD_ZoomImage $img_malus_l1]
      .board.c create image 285 166 -image $img_malus_l1 -tags img_malus_l1 -anchor nw
    }
    if { [lindex $malus_r 0] == 1 } {
      set img_malus_r0 [image create photo]
      $img_malus_r0 read "$SCRIPT_PATH/imgs/malus2.png"
      set img_malus_r0 [BOARD_ZoomImage $img_malus_r0]
      .board.c create image 712 170 -image $img_malus_r0 -tags img_malus_r0 -anchor nw
    }
    if { [lindex $malus_r 1] == 1 } {
      set img_malus_r1 [image create photo]
      $img_malus_r1 read "$SCRIPT_PATH/imgs/malus5.png"
      set img_malus_r1 [BOARD_ZoomImage $img_malus_r1]
      .board.c create image 823 166 -image $img_malus_r1 -tags img_malus_r1 -anchor nw
    }

    # Display warrior
    set pos $game_state(warrior)
    set img_warrior [image create photo]
    $img_warrior read "$SCRIPT_PATH/imgs/warrior.png"
    set img_warrior [BOARD_ZoomImage $img_warrior]
    if { ($PLAYER_NAME == $game_state(player_first)) || ($PLAYER_OBS == 1) } {
      .board.c create image [expr 583 + ($pos * 38.5)] 81 -image $img_warrior -tags img_warrior -anchor nw
    } else {
      .board.c create image [expr 583 + ($pos * -38.5)] 81 -image $img_warrior -tags img_warrior -anchor nw
    }
    # Must select the warrior
    if { $game_state(action_warrior) == 1 } {
      set coords [.board.c coords img_warrior]
      set x1 [lindex $coords 0]
      set y1 [lindex $coords 1]
      set x2 [expr 32 + $x1]
      set y2 [expr 92 + $y1]
      .board.c create oval $x1 [expr $y1 + 15] $x2 [expr $y2 - 15] -outline "purple3" -width 4 -tags img_actions
    }

    # Display game set #1
    if { $game_state(round) == 1 } {
      # Game set #1
      set img_back [image create photo]
      $img_back read "$SCRIPT_PATH/imgs/mini_cards1_back.png"
      set img_back [BOARD_ZoomImage $img_back]
      for { set i 0 } { $i < 20 } { incr i } {
        if { [llength $game_state(cards1)] > $i } {
          array set card [lindex $game_state(cards1) $i]
          if { $card(owner) == "" } {
            set img_card [image create photo]
            $img_card read "$SCRIPT_PATH/imgs/mini_$card(image)"
            set img_card [BOARD_ZoomImage $img_card]
            set auto $img_back
            if { [TOOLS_IsCardSelectable $i] } { set auto $img_card }
            if { $i == 0  } { .board.c create image 485 228 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 1  } { .board.c create image 615 228 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 2  } { .board.c create image 420 293 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 3  } { .board.c create image 550 293 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 4  } { .board.c create image 680 293 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 5  } { .board.c create image 355 358 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 6  } { .board.c create image 485 358 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 7  } { .board.c create image 615 358 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 8  } { .board.c create image 745 358 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 9  } { .board.c create image 290 423 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 10 } { .board.c create image 420 423 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 11 } { .board.c create image 550 423 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 12 } { .board.c create image 680 423 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 13 } { .board.c create image 810 423 -image $auto     -tags img_card1_$i -anchor nw }
            if { $i == 14 } { .board.c create image 225 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 15 } { .board.c create image 355 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 16 } { .board.c create image 485 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 17 } { .board.c create image 615 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 18 } { .board.c create image 745 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { $i == 19 } { .board.c create image 875 488 -image $img_card -tags img_card1_$i -anchor nw }
            if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsCardSelectable $i] == 1) } {
              .board.c bind img_card1_$i <ButtonRelease-1> "ACTION_DisplayActionCard $i"
              .board.c bind img_card1_$i <Leave> "BOARD_HighlightCard $i 0"
              .board.c bind img_card1_$i <Enter> "BOARD_HighlightCard $i 1"
            } else {
              .board.c bind img_card1_$i <ButtonRelease-1> ""
              .board.c bind img_card1_$i <Enter> ""
            }
          }
        }
      }
    }

    # Display game set #2
    if { $game_state(round) == 2 } {
      # Game set #2
      set img_back [image create photo]
      $img_back read "$SCRIPT_PATH/imgs/mini_cards2_back.png"
      set img_back [BOARD_ZoomImage $img_back]
      for { set i 0 } { $i < 20 } { incr i } {
        if { [llength $game_state(cards2)] > $i } {
          array set card [lindex $game_state(cards2) $i]
          if { $card(owner) == "" } {
            set img_card [image create photo]
            $img_card read "$SCRIPT_PATH/imgs/mini_$card(image)"
            set img_card [BOARD_ZoomImage $img_card]
            set auto $img_back
            if { [TOOLS_IsCardSelectable $i] } { set auto $img_card }
            if { $i == 0  } { .board.c create image 225 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 1  } { .board.c create image 355 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 2  } { .board.c create image 485 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 3  } { .board.c create image 615 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 4  } { .board.c create image 745 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 5  } { .board.c create image 875 228 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 6  } { .board.c create image 290 293 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 7  } { .board.c create image 420 293 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 8  } { .board.c create image 550 293 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 9  } { .board.c create image 680 293 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 10 } { .board.c create image 810 293 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 11 } { .board.c create image 355 358 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 12 } { .board.c create image 485 358 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 13 } { .board.c create image 615 358 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 14 } { .board.c create image 745 358 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 15 } { .board.c create image 420 423 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 16 } { .board.c create image 550 423 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 17 } { .board.c create image 680 423 -image $auto     -tags img_card2_$i -anchor nw }
            if { $i == 18 } { .board.c create image 485 488 -image $img_card -tags img_card2_$i -anchor nw }
            if { $i == 19 } { .board.c create image 615 488 -image $img_card -tags img_card2_$i -anchor nw }
            if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsCardSelectable $i] == 1) } {
              .board.c bind img_card2_$i <ButtonRelease-1> "ACTION_DisplayActionCard $i"
              .board.c bind img_card2_$i <Leave> "BOARD_HighlightCard $i 0"
              .board.c bind img_card2_$i <Enter> "BOARD_HighlightCard $i 1"
            } else {
              .board.c bind img_card2_$i <ButtonRelease-1> ""
              .board.c bind img_card2_$i <Enter> ""
            }
          }
        }
      }
    }

    # Display game set #3/4
    if { $game_state(round) == 3 } {
      # Game set #3/4
      set img_back3 [image create photo]
      set img_back4 [image create photo]
      $img_back3 read "$SCRIPT_PATH/imgs/mini_cards3_back.png"
      $img_back4 read "$SCRIPT_PATH/imgs/mini_cards4_back.png"
      set img_back3 [BOARD_ZoomImage $img_back3]
      set img_back4 [BOARD_ZoomImage $img_back4]
      for { set i 0 } { $i < 20 } { incr i } {
        if { [llength $game_state(cards3)] > $i } {
          array set card [lindex $game_state(cards3) $i]
          if { $card(owner) == "" } {
            set img_card [image create photo]
            $img_card read "$SCRIPT_PATH/imgs/mini_$card(image)"
            set img_card [BOARD_ZoomImage $img_card]
            if { [TOOLS_IsCardSelectable $i] } {
              set auto $img_card
            } else {
              if { [string index $card(image) 5] == "3" } { set auto $img_back3 }
              if { [string index $card(image) 5] == "4" } { set auto $img_back4 }
            }
            if { $i == 0  } { .board.c create image 485 228 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 1  } { .board.c create image 615 228 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 2  } { .board.c create image 420 288 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 3  } { .board.c create image 550 288 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 4  } { .board.c create image 680 288 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 5  } { .board.c create image 355 348 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 6  } { .board.c create image 485 348 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 7  } { .board.c create image 615 348 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 8  } { .board.c create image 745 348 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 9  } { .board.c create image 420 408 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 10 } { .board.c create image 680 408 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 11 } { .board.c create image 355 468 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 12 } { .board.c create image 485 468 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 13 } { .board.c create image 615 468 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 14 } { .board.c create image 745 468 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 15 } { .board.c create image 420 528 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 16 } { .board.c create image 550 528 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 17 } { .board.c create image 680 528 -image $auto     -tags img_card3_$i -anchor nw }
            if { $i == 18 } { .board.c create image 485 588 -image $img_card -tags img_card3_$i -anchor nw }
            if { $i == 19 } { .board.c create image 615 588 -image $img_card -tags img_card3_$i -anchor nw }
            if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsCardSelectable $i] == 1) } {
              .board.c bind img_card3_$i <ButtonRelease-1> "ACTION_DisplayActionCard $i"
              .board.c bind img_card3_$i <Leave> "BOARD_HighlightCard $i 0"
              .board.c bind img_card3_$i <Enter> "BOARD_HighlightCard $i 1"
            } else {
              .board.c bind img_card3_$i <ButtonRelease-1> ""
              .board.c bind img_card3_$i <Enter> ""
            }
          }
        }
      }
    }

    # Display players cards
    TOOLS_FillPlayersCards $PLAYER_NAME $PLAYER_OBS
    set nb_cards_by_colomn 15
    set num 0
    foreach tcard $CARDS_P1 {
      array set card $tcard
      set img_card [image create photo]
      $img_card read "$SCRIPT_PATH/imgs/mini_$card(image)"
      set img_card [BOARD_ZoomImage $img_card]
      .board.c create image [expr ($num / $nb_cards_by_colomn) * 100] \
                            [expr (($num % $nb_cards_by_colomn) * 35) + 100] \
                     -image $img_card -tags img_cards_p1_$num -anchor nw
      # Must select the card (obs)
      if { $game_state(action_card) == $card(name) } {
        set coords [.board.c coords img_cards_p1_$num]
        set x1 [expr [lindex $coords 0] + 2]
        set y1 [expr [lindex $coords 1] + 2]
        set x2 [expr 100 + $x1 - 4]
        if { [TOOLS_IsLastCard $num $card(owner)] == 1 } {
          set y2 [expr 155 + $y1 - 4]
        } else {
          set y2 [expr 35  + $y1 - 4]
        }
        TOOLS_FillPlayersCards $PLAYER_NAME $PLAYER_OBS
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_actions
      }
      incr num
    }
    set num 0
    foreach tcard $CARDS_P2 {
      array set card $tcard
      set img_card [image create photo]
      $img_card read "$SCRIPT_PATH/imgs/mini_$card(image)"
      set img_card [BOARD_ZoomImage $img_card]
      .board.c create image [expr 1100 - (($num / $nb_cards_by_colomn) * 100)] \
                            [expr (($num % $nb_cards_by_colomn) * 35) + 100] \
                     -image $img_card -tags img_cards_p2_$num -anchor nw
      if { ([GUI_IsPlaying] == 1) && ([TOOLS_IsBrownCardSelectable $PLAYER_NAME $num] == 1) } {
        .board.c bind img_cards_p2_$num <ButtonRelease-1> "ACTION_BuildWonderAndDiscard 3 $num"
        .board.c bind img_cards_p2_$num <Leave> "BOARD_HighlightBrownCard $num 0"
        .board.c bind img_cards_p2_$num <Enter> "BOARD_HighlightBrownCard $num 1"
      } elseif { ([GUI_IsPlaying] == 1) && ([TOOLS_IsGrayCardSelectable $PLAYER_NAME $num] == 1) } {
        .board.c bind img_cards_p2_$num <ButtonRelease-1> "ACTION_BuildWonderAndDiscard 4 $num"
        .board.c bind img_cards_p2_$num <Leave> "BOARD_HighlightGrayCard $num 0"
        .board.c bind img_cards_p2_$num <Enter> "BOARD_HighlightGrayCard $num 1"
      } else {
        .board.c bind img_cards_p2_$num <ButtonRelease-1> ""
        .board.c bind img_cards_p2_$num <Enter> ""
      }
      TOOLS_FillPlayersCards $PLAYER_NAME $PLAYER_OBS
      # Must select the card
      if { $game_state(action_card) == $card(name) } {
        set coords [.board.c coords img_cards_p2_$num]
        set x1 [expr [lindex $coords 0] + 2]
        set y1 [expr [lindex $coords 1] + 2]
        set x2 [expr 100 + $x1 - 4]
        if { [TOOLS_IsLastCard $num $card(owner)] == 1 } {
          set y2 [expr 155 + $y1 - 4]
        } else {
          set y2 [expr 35  + $y1 - 4]
        }
        TOOLS_FillPlayersCards $PLAYER_NAME $PLAYER_OBS
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "purple3" -width 4 -tags img_actions
      }
      incr num
    }
    .board.c scale all 0 0 [expr $ZOOM_IN.0 / $ZOOM_OUT.0] [expr $ZOOM_IN.0 / $ZOOM_OUT.0]
    foreach name [image names] {
      if { (![image inuse $name]) && ([string index $name 0] != ":") } { image delete $name }
    }

    catch { focus .board.chat.fm.t }
  }
}

# Manage selection
after 200 "BOARD_ManageSelection"
proc BOARD_ManageSelection {} {
  variable CARD_INDEX
  variable WONDER_INDEX
  variable JETON_INDEX
  variable BROWN_INDEX
  variable GRAY_INDEX
  variable DISCARD_INDEX
  variable JETON3_INDEX
  variable PLAYER_NAME
  variable SCRIPT_PATH
  variable MODE_SEL
  variable DISCARD
  variable forever
  variable game_state

  if { [winfo exists .board.discard.c] } {
    .board.discard.c delete img_rect_discard
    # Discarded card selection
    if { ($DISCARD_INDEX >= 0) && ($MODE_SEL == 5) } {
      catch {
        set coords [.board.discard.c coords img_dcards$DISCARD_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr 170 + $x1]
        set y2 [expr 260 + $y1]
        .board.discard.c create rectangle $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_rect_discard
      }
    }
  }

  if { [winfo exists .board.jetons.c] } {
    .board.jetons.c delete img_oval_jeton3
    # Jeton3 selection
    if { ($JETON3_INDEX >= 0) && ($MODE_SEL == 6) } {
      catch {
        set coords [.board.jetons.c coords img_jeton3_$JETON3_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr 67 + $x1]
        set y2 [expr 67 + $y1]
        .board.jetons.c create oval $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_oval_jeton3
      }
    }
  }

  if { [winfo exists .board.c] } {
    .board.c delete img_rect_card img_rect_wonder img_oval_jeton img_rect_brown img_rect_gray img_oval_discard
    if { ($CARD_INDEX >= 0) && ($MODE_SEL == 0) } {
      # Determine if the card#1 is selectable
      set round $game_state(round)
      if { ([.board.c gettags img_card[set round]_$CARD_INDEX] != "") && ([TOOLS_IsCardSelectable $CARD_INDEX] == 1) } {
        set coords [.board.c coords img_card[set round]_$CARD_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr [BOARD_Scale 100] + $x1]
        set y2 [expr [BOARD_Scale 155] + $y1]
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_rect_card
      }
    }
    if { ($WONDER_INDEX >= 0) && ($MODE_SEL == 1) } {
      # Determine if a wonder is buyable
      if { ([.board.c gettags img_wonder$WONDER_INDEX] != "") && ([TOOLS_IsWonderSelectable $PLAYER_NAME $WONDER_INDEX] == 1) } {
        set coords [.board.c coords img_wonder$WONDER_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr [BOARD_Scale 150] + $x1]
        set y2 [expr [BOARD_Scale  98] + $y1]
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_rect_wonder
      }
    }
    if { ($JETON_INDEX >= 0) && (($MODE_SEL == 2) || ($MODE_SEL == 7)) } {
      # Determine if a jeton can be taken
      if { ([.board.c gettags img_jeton$JETON_INDEX] != "") && ([TOOLS_IsJetonSelectable $JETON_INDEX] == 1) } {
        set coords [.board.c coords img_jeton$JETON_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr [BOARD_Scale 67] + $x1]
        set y2 [expr [BOARD_Scale 67] + $y1]
        .board.c create oval $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_oval_jeton
      }
    }
    if { ($BROWN_INDEX >= 0) && ($MODE_SEL == 3) } {
      # Determine if a brown card can be discard
      if { ([.board.c gettags img_cards_p2_$BROWN_INDEX] != "") && ([TOOLS_IsBrownCardSelectable $PLAYER_NAME $BROWN_INDEX] == 1) } {
        set coords [.board.c coords img_cards_p2_$BROWN_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr [BOARD_Scale 100] + $x1]
        if { [TOOLS_IsLastCard $BROWN_INDEX] == 1 } {
          set y2 [expr [BOARD_Scale 155] + $y1]
        } else {
          set y2 [expr [BOARD_Scale 35] + $y1]
        }
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_rect_brown
      }
    }
    if { ($GRAY_INDEX >= 0) && ($MODE_SEL == 4) } {
      # Determine if a gray card can be discard
      if { ([.board.c gettags img_cards_p2_$GRAY_INDEX] != "") && ([TOOLS_IsGrayCardSelectable $PLAYER_NAME $GRAY_INDEX] == 1) } {
        set coords [.board.c coords img_cards_p2_$GRAY_INDEX]
        set x1 [lindex $coords 0]
        set y1 [lindex $coords 1]
        set x2 [expr [BOARD_Scale 100] + $x1]
        if { [TOOLS_IsLastCard $GRAY_INDEX] == 1 } {
          set y2 [expr [BOARD_Scale 155] + $y1]
        } else {
          set y2 [expr [BOARD_Scale 35] + $y1]
        }
        .board.c create rectangle $x1 $y1 $x2 $y2 -outline "goldenrod2" -width 2 -tags img_rect_gray
      }
    }
    # Discard selection
    if { $DISCARD == 1 } {
      set coords [.board.c coords img_discard]
      set x1 [lindex $coords 0]
      set y1 [lindex $coords 1]
      set x2 [expr [BOARD_Scale 34] + $x1]
      set y2 [expr [BOARD_Scale 36] + $y1]
      .board.c create oval $x1 [expr $y1 + 2] $x2 $y2 -outline "goldenrod2" -width 2 -tags img_oval_discard
    }
  }
  if { $forever == 1 } { after 50 "BOARD_ManageSelection" }
}

# Card highlighting
proc BOARD_HighlightCard {index value} {
  variable CARD_INDEX
  variable MODE_SEL

  if { $value    == 0 } { set CARD_INDEX -1 }
  if { $MODE_SEL != 0 } { return }
  if { $value    == 1 } { set CARD_INDEX $index }
}

# Wonder highlighting
proc BOARD_HighlightWonder {index value} {
  variable WONDER_INDEX
  variable MODE_SEL

  if { $value    == 0 } { set WONDER_INDEX -1 }
  if { $MODE_SEL != 1 } { return }
  if { $value    == 1 } { set WONDER_INDEX $index }
}

# Jeton highlighting
proc BOARD_HighlightJeton {index value} {
  variable JETON_INDEX
  variable MODE_SEL

  BOARD_InfoJeton $index $value
  if { ($MODE_SEL != 2) && ($MODE_SEL != 7) } { return }
  if { $value == 1 } { set JETON_INDEX $index }
}

# Jeton info
variable INFO_JETON
set INFO_JETON ""
proc BOARD_InfoJeton {index value} {
  variable game_state
  variable INFO_JETON
  variable JETON_INDEX

  if { $value == 1 } {
    array set jeton [lindex $game_state(jetons) $index]
    set INFO_JETON "$jeton(desc)"
  } else {
    set JETON_INDEX -1
    set INFO_JETON ""
  }
  BOARD_ManageInfoMessage
}

# Brown card highlighting
proc BOARD_HighlightBrownCard {index value} {
  variable BROWN_INDEX
  variable MODE_SEL
  if { $value    == 0 } { set BROWN_INDEX -1 }
  if { $MODE_SEL != 3 } { return }
  if { $value    == 1 } { set BROWN_INDEX $index }
}

# Gray card highlighting
proc BOARD_HighlightGrayCard {index value} {
  variable GRAY_INDEX
  variable MODE_SEL

  if { $value    == 0 } { set GRAY_INDEX -1 }
  if { $MODE_SEL != 4 } { return }
  if { $value    == 1 } { set GRAY_INDEX $index }
}

# Discard highlighting
proc BOARD_HighlightDiscard {value} {
  variable DISCARD

  set DISCARD $value
}

# Manage information message
variable INFO_BAR
set INFO_BAR(0) {  "<=" "=>"  }
set INFO_BAR(1) { "<==" "==>" }
set INFO_BAR(2) {"<===" "===>"}
variable INFO_SEL
set INFO_SEL 0

proc BOARD_ManageInfoMessage {} {
  variable MODE_SEL
  variable PLAYER_NAME
  variable PLAYER_OBS
  variable WAIT_RECO
  variable WAIT_BAR
  variable DORECO
  variable game_state
  variable INFO_BAR
  variable INFO_SEL
  variable INFO_JETON

  after 500 "BOARD_ManageWaitAuto"
  incr INFO_SEL
  if { $INFO_SEL >= 12 } { set INFO_SEL 0 }
  if { $DORECO == 1 } { return }
  if { $INFO_JETON != "" } {
    GUI_ShowInfo "$INFO_JETON" "DarkBlue"
    catch { focus .board.chat.fm.t }
    return
  }
  if { [GUI_IsPlaying] == 1 } {
    if { $game_state(player_turn) <= 8 } {
      GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] A VOUS DE JOUER: SELECTIONNEZ UNE MERVEILLE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue"
    } else {
      if { $MODE_SEL == 0 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] A VOUS DE JOUER: SELECTIONNEZ UNE CARTE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 1 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ LA MERVEILLE A CONSTRUIRE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 2 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ LE JETON SCIENCE A CONSTRUIRE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 3 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ UNE CARTE MARRON DE L'ADVERSAIRE A RENVOYER DANS LA DEFAUSSE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 4 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ UNE CARTE GRISE DE L'ADVERSAIRE A RENVOYER DANS LA DEFAUSSE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 5 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ UNE CARTE DE LA DEFAUSSE A CONSTRUIRE GRATUITEMENT [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 6 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ LE JETON SCIENCE A CONSTRUIRE PARMI LES 3 PROPOSES [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
      if { $MODE_SEL == 7 } { GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] SELECTIONNEZ LE JETON SCIENCE A CONSTRUIRE [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue" }
    }
  } else {
    if { $game_state(player_turn) >= 0 } {
      if  { ($game_state(play) != "") && ($game_state($game_state(play)) != "") } {
        if { $PLAYER_OBS == 1 } {
          GUI_ShowInfo "C'est a $game_state($game_state(play)) de jouer" "black"
        } else {
          GUI_ShowInfo "Attente que le joueur $game_state($game_state(play)) finisse son tour de jeu..." "DarkRed"
        }
      } else {
        if { $game_state(newround) != "" } {
          if { $PLAYER_OBS == 1 } {
            GUI_ShowInfo "C'est a $game_state($game_state(newround)) de choisir qui va commencer le nouveau round" "black"
          } elseif { [TOOLS_IsNewRound $PLAYER_NAME] == 0 } {
            GUI_ShowInfo "Attente que le joueur $game_state($game_state(newround)) choisisse qui commence le nouveau round" "DarkRed"
          } else {
            GUI_ShowInfo "[lindex $INFO_BAR([expr $INFO_SEL / 4]) 0] CHOISISSEZ LE JOUEUR QUI VA COMMENCER LE PROCHAIN ROUND [lindex $INFO_BAR([expr $INFO_SEL / 4]) 1]" "DarkBlue"
          }
        } else {
          GUI_ShowInfo "Attente que les autres joueurs se connectent et rejoignent le jeu... $WAIT_BAR($WAIT_RECO)" "DarkRed"
        }
      }
    }
  }
}

# Auto-reconnexion
variable DORECO
set DORECO 0
variable WAIT_BAR
set WAIT_BAR(0) "|"
set WAIT_BAR(1) "/"
set WAIT_BAR(2) "-"
set WAIT_BAR(3) "\\"
variable WAIT_RECO
set WAIT_RECO 0

proc BOARD_ManageWaitAuto {} {
  variable WAIT_RECO
  variable WAIT_BAR
  variable tcp_socket
  variable DORECO

  incr WAIT_RECO
  if { $WAIT_RECO >= 4 } { set WAIT_RECO 0 }
  if { [catch { puts $tcp_socket "TestConnexion" }] } {
    GUI_ShowInfo "!! VOUS AVEZ ETE DECONNECTE, TENTATIVE DE RECONNEXION $WAIT_BAR($WAIT_RECO) !!" "DarkRed"
    set game_state(play) ""
    catch { unset tcp_socket }
    if { $DORECO == 0 } {
      set DORECO 1
      after 1000 "GUI_ConnectToServer ; variable DORECO ; set DORECO 0"
    }
  }
}

