#!/usr/bin/tclsh

# Configure shortcuts
proc TOOLS_SetShortcuts {window} {
  bind $window <KeyPress-F2>  "BOARD_Save"
  bind $window <KeyPress-F3>  "BOARD_Load"
  bind $window <KeyPress-F5>  "BOARD_RefreshGame"
  bind $window <KeyPress-F6>  "BOARD_PlayBack"
  bind $window <KeyPress-F7>  "BOARD_PlayNext"
  bind $window <KeyPress-F8>  "BOARD_ChangeZoom"
  bind $window <KeyPress-F10> "BOARD_New $window"
  bind $window <KeyPress-F12> "BOARD_KillServer"
}

# Tell if we are playing
proc GUI_IsPlaying {} {
  variable game_state
  variable PLAYER_NAME
  variable PLAYER_OBS

  if { $game_state(play) == "" } { return 0 }
  if { $game_state(round) > 3  } { return 0 }
  if { $PLAYER_OBS == 1 } { return 0 }
  if { $game_state($game_state(play)) == $PLAYER_NAME } { return 1 }
  return 0
}

# Determine if it is the last card of the other player (or of a column)
proc TOOLS_IsLastCard {index {play ""}} {
  variable game_state
  variable PLAYER_NAME
  variable CARDS_P2

  if { $play == "" } {
    set name $PLAYER_NAME
  } else {
    if { $play == "player_first"  } { set name $game_state(player_second) }
    if { $play == "player_second" } { set name $game_state(player_first)  }
  }
  TOOLS_FillPlayersCards $name 0
  if { [expr $index + 1] == [llength $CARDS_P2] } { return 1 }
  if { [expr $index % 15] == 14 } { return 1 }
  return 0
}

# Indicate if 1 or 2 cards are taken (by a player or discarded)
proc TOOLS_TakenCards {index1 {index2 -1}} {
  variable game_state

  set round $game_state(round)
  array set card1 [lindex $game_state(cards$round) $index1]
  if { $index2 >= 0 } {
    array set card2 [lindex $game_state(cards$round) $index2]
    if { ($card1(owner) != "") && ($card2(owner) != "") } { return 1 }
  } else {
    if { $card1(owner) != "" } { return 1 }
  }
  return 0
}

# Determine if the card is selectable/visible
proc TOOLS_IsCardSelectable {index} {
  variable game_state

  if { [TOOLS_TakenCards $index] == 1 } { return 0 }
  array set show ""
  if { $game_state(round) == 1 } {
    set show(0)  [TOOLS_TakenCards 2 3]
    set show(1)  [TOOLS_TakenCards 3 4]
    set show(2)  [TOOLS_TakenCards 5 6]
    set show(3)  [TOOLS_TakenCards 6 7]
    set show(4)  [TOOLS_TakenCards 7 8]
    set show(5)  [TOOLS_TakenCards 9 10]
    set show(6)  [TOOLS_TakenCards 10 11]
    set show(7)  [TOOLS_TakenCards 11 12]
    set show(8)  [TOOLS_TakenCards 12 13]
    set show(9)  [TOOLS_TakenCards 14 15]
    set show(10) [TOOLS_TakenCards 15 16]
    set show(11) [TOOLS_TakenCards 16 17]
    set show(12) [TOOLS_TakenCards 17 18]
    set show(13) [TOOLS_TakenCards 18 19]
    set show(14) 1
    set show(15) 1
    set show(16) 1
    set show(17) 1
    set show(18) 1
    set show(19) 1
  }
  if { $game_state(round) == 2 } {
    set show(0)  [TOOLS_TakenCards 6]
    set show(1)  [TOOLS_TakenCards 6 7]
    set show(2)  [TOOLS_TakenCards 7 8]
    set show(3)  [TOOLS_TakenCards 8 9]
    set show(4)  [TOOLS_TakenCards 9 10]
    set show(5)  [TOOLS_TakenCards 10]
    set show(6)  [TOOLS_TakenCards 11]
    set show(7)  [TOOLS_TakenCards 11 12]
    set show(8)  [TOOLS_TakenCards 12 13]
    set show(9)  [TOOLS_TakenCards 13 14]
    set show(10) [TOOLS_TakenCards 14]
    set show(11) [TOOLS_TakenCards 15]
    set show(12) [TOOLS_TakenCards 15 16]
    set show(13) [TOOLS_TakenCards 16 17]
    set show(14) [TOOLS_TakenCards 17]
    set show(15) [TOOLS_TakenCards 18]
    set show(16) [TOOLS_TakenCards 18 19]
    set show(17) [TOOLS_TakenCards 19]
    set show(18) 1
    set show(19) 1
  }
  if { $game_state(round) == 3 } {
    set show(0)  [TOOLS_TakenCards 2 3]
    set show(1)  [TOOLS_TakenCards 3 4]
    set show(2)  [TOOLS_TakenCards 5 6]
    set show(3)  [TOOLS_TakenCards 6 7]
    set show(4)  [TOOLS_TakenCards 7 8]
    set show(5)  [TOOLS_TakenCards 9]
    set show(6)  [TOOLS_TakenCards 9]
    set show(7)  [TOOLS_TakenCards 10]
    set show(8)  [TOOLS_TakenCards 10]
    set show(9)  [TOOLS_TakenCards 11 12]
    set show(10) [TOOLS_TakenCards 13 14]
    set show(11) [TOOLS_TakenCards 15]
    set show(12) [TOOLS_TakenCards 15 16]
    set show(13) [TOOLS_TakenCards 16 17]
    set show(14) [TOOLS_TakenCards 17]
    set show(15) [TOOLS_TakenCards 18]
    set show(16) [TOOLS_TakenCards 18 19]
    set show(17) [TOOLS_TakenCards 19]
    set show(18) 1
    set show(19) 1
  }
  return $show($index)
}

# Determine if the wonder is selectable
proc TOOLS_IsWonderSelectable {name index} {
  variable game_state

  array set wonder [lindex $game_state(wonders) $index]
  if { ($wonder(built) == 0) && ($game_state($wonder(owner)) == $name) } {
    if { [TOOLS_GetLastWonder] == -1 } {
      return 1
    }
  }
  return 0
}

# Determine if a jeton is selectable
proc TOOLS_IsJetonSelectable {index} {
  variable game_state

  if { $index < 0 } { return 0 }
  array set jeton [lindex $game_state(jetons) $index]
  if { $jeton(owner) != "" } { return 0 }
  return 1
}

# Determine if a brown card is selectable
proc TOOLS_IsBrownCardSelectable {name index} {
  variable CARDS_P2

  if { $index < 0 } { return 0 }
  TOOLS_FillPlayersCards $name 0
  array set card [lindex $CARDS_P2 $index]
  if { $card(color) == "brown" } { return 1 }
  return 0
}

# Determine if a gray card is selectable
proc TOOLS_IsGrayCardSelectable {name index} {
  variable CARDS_P2

  if { $index < 0 } { return 0 }
  TOOLS_FillPlayersCards $name 0
  array set card [lindex $CARDS_P2 $index]
  if { $card(color) == "gray" } { return 1 }
  return 0
}

# Return index with maximum value
proc TOOLS_Max { fund_list cost_list } {
  set index 0
  set max -1
  set max_index -1
  foreach fund $fund_list {
    if { $fund > 0 } {
      if { [lindex $cost_list $index] > $max } {
        set max_index $index
        set max [lindex $cost_list $index]
      }
    }
    incr index
  }
  return $max_index
}

# Compute the price of an element
proc TOOLS_GetPrice {name obs price {joker 0}} {
  variable FUNDS_P1
  variable FUNDS_P2
  variable game_state

  # Observator
  if { $obs == 1 } { return 0 }

  # Get players funds
  TOOLS_FillPlayersFunds $name $obs

  # Compute card cost at market
  set cost(0) [expr 2 + [lindex $FUNDS_P2 0]]
  set cost(1) [expr 2 + [lindex $FUNDS_P2 1]]
  set cost(2) [expr 2 + [lindex $FUNDS_P2 2]]
  set cost(3) [expr 2 + [lindex $FUNDS_P2 3]]
  set cost(4) [expr 2 + [lindex $FUNDS_P2 4]]
  if { [lindex $FUNDS_P1 7 ] > 0 } { set cost(0) 1 }
  if { [lindex $FUNDS_P1 8 ] > 0 } { set cost(1) 1 }
  if { [lindex $FUNDS_P1 9 ] > 0 } { set cost(2) 1 }
  if { [lindex $FUNDS_P1 10] > 0 } {
    set cost(3) 1
    set cost(4) 1
  }

  # Compute funds to pay
  set fund(0) [expr [lindex $price 0] - [lindex $FUNDS_P1 0]]
  set fund(1) [expr [lindex $price 1] - [lindex $FUNDS_P1 1]]
  set fund(2) [expr [lindex $price 2] - [lindex $FUNDS_P1 2]]
  set fund(3) [expr [lindex $price 3] - [lindex $FUNDS_P1 3]]
  set fund(4) [expr [lindex $price 4] - [lindex $FUNDS_P1 4]]
  if { $fund(0) < 0 } { set fund(0) 0 }
  if { $fund(1) < 0 } { set fund(1) 0 }
  if { $fund(2) < 0 } { set fund(2) 0 }
  if { $fund(3) < 0 } { set fund(3) 0 }
  if { $fund(4) < 0 } { set fund(4) 0 }

  # Wood-Clay-Stone trade reduction
  set nb_trade [lindex $FUNDS_P1 5]
  for { set i 0 } { $i < $nb_trade } { incr i } {
    # Pay one wood/clay/stone
    set index [TOOLS_Max [list $fund(0) $fund(1) $fund(2)] [list $cost(0) $cost(1) $cost(2)]]
    if { $index != -1 } { set fund($index) [expr $fund($index) - 1] }
  }

  # Parchment-Potion trade reduction
  set nb_trade [lindex $FUNDS_P1 6]
  for { set i 0 } { $i < $nb_trade } { incr i } {
    # Pay one parchment/potion
    set index [TOOLS_Max [list $fund(3) $fund(4)] [list $cost(3) $cost(4)]]
    if { $index != -1 } {
      set index [expr $index + 3]
      set fund($index) [expr $fund($index) - 1]
    }
  }

  # Joker reduction
  for { set i 0 } { $i < $joker } { incr i } {
    # Pay one wood/clay/stone/parchment/potion
    set index [TOOLS_Max [list $fund(0) $fund(1) $fund(2) $fund(3) $fund(4)] [list $cost(0) $cost(1) $cost(2) $cost(3) $cost(4)]]
    if { $index != -1 } { set fund($index) [expr $fund($index) - 1] }
  }

  # Compute best price for paying funds
  set total_cost [lindex $price 5]
  set total_cost [expr $total_cost + ($fund(0) * $cost(0)) + \
                                     ($fund(1) * $cost(1)) + \
                                     ($fund(2) * $cost(2)) + \
                                     ($fund(3) * $cost(3)) + \
                                     ($fund(4) * $cost(4))]

  return $total_cost
}

# Compute the price of a card
proc TOOLS_GetCardPrice {index name obs} {
  variable game_state
  variable CARDS_P1

  # Observator
  if { $obs == 1 } { return 0 }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Get card details
  set j $game_state(round)
  array set card [lindex $game_state(cards$j) $index]

  # Look if we have a chain (free)
  set chain [lindex $card(chain) 1]
  if { $chain > 0 } {
    TOOLS_FillPlayersCards $name $obs
    foreach tcard_p1 $CARDS_P1 {
      array set card_p1 $tcard_p1
      if { [lindex $card_p1(chain) 0] == $chain } { return -1 }
    }
  }

  # Get card price
  if { ([TOOLS_IsJetonBought "MACONNERIE" $name $obs]) && ($card(color) == "blue") } {
    set price [TOOLS_GetPrice $name $obs $card(price) 2]
  } else {
    set price [TOOLS_GetPrice $name $obs $card(price)]
  }
  return $price
}

# Compute the price of a wonder
proc TOOLS_GetWonderPrice {index name obs} {
  variable game_state

  # Observator
  if { $obs == 1 } { return 0 }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Get wonder details
  array set wonder [lindex $game_state(wonders) $index]

  # Get wonder price
  if { [TOOLS_IsJetonBought "ARCHITECTURE" $name $obs] } {
    set price [TOOLS_GetPrice $name $obs $wonder(price) 2]
  } else {
    set price [TOOLS_GetPrice $name $obs $wonder(price)]
  }
  return $price
}

# Replace a card
proc TOOLS_ReplaceCard {new_card} {
  variable game_state

  # Find the card (by its name)
  array set ncard $new_card
  for { set j 1 } { $j <= 3 } { incr j } {
    for { set i 0 } { $i < 20 } { incr i } {
      if { [llength $game_state(cards$j)] > $i } {
        array set card [lindex $game_state(cards$j) $i]
        if { $card(name) == $ncard(name) } {
          set game_state(cards$j) [lreplace $game_state(cards$j) $i $i $new_card]
        }
      }
    }
  }
}

# Fill players cards
proc TOOLS_FillPlayersCards {name obs} {
  variable CARDS_P1
  variable CARDS_P2
  variable game_state

  # Find players cards
  set cards_player1 {}
  set cards_player2 {}
  for { set j 1 } { $j <= 3 } { incr j } {
    for { set i 0 } { $i < 20 } { incr i } {
      if { [llength $game_state(cards$j)] > $i } {
        array set card [lindex $game_state(cards$j) $i]
        if { ($card(owner) != "") && ($card(owner) != "discard") && ($card(owner) != "wonder") } {
          if { ($game_state($card(owner)) == $name) ||
               (($obs == 1) && ($card(owner) == "player_first")) ||
               (($game_state(player_first) == "") && ($game_state(player_second) == "") && ($card(owner) == "player_first")) } {
            lappend cards_player1 [array get card]
          } else {
            lappend cards_player2 [array get card]
          }
        }
      }
    }
  }

  # Order cards
  set order {"brown" "gray" "yellow" "blue" "green" "red" "purple"}
  set CARDS_P1 {}
  set CARDS_P2 {}
  for { set i 0 } { $i < [llength $order] } { incr i } {
    foreach tcard $cards_player1 {
      array set card $tcard
      if { $card(color) == [lindex $order $i] } {
        lappend CARDS_P1 [array get card]
      }
    }
    foreach tcard $cards_player2 {
      array set card $tcard
      if { $card(color) == [lindex $order $i] } {
        lappend CARDS_P2 [array get card]
      }
    }
  }
}

# Fill players funds
proc TOOLS_FillPlayersFunds {name obs} {
  variable FUNDS_P1
  variable FUNDS_P2
  variable game_state

  # Wood / Clay / Stone / Parchment / Potion // Wood-Clay-Stone / Parchment-Potion // Wood(1) / Clay(1) / Stone(1) / Parchment-Potion(1)
  set FUNDS_P1 {0 0 0 0 0  0 0  0 0 0 0}
  set FUNDS_P2 {0 0 0 0 0  0 0  0 0 0 0}

  # No funds for observators
  if { $obs == 1 } { return }

  # Count players funds
  for { set j 1 } { $j <= 3 } { incr j } {
    for { set i 0 } { $i < 20 } { incr i } {
      if { [llength $game_state(cards$j)] > $i } {
        array set card [lindex $game_state(cards$j) $i]
        if { ($card(owner) != "") && ($card(owner) != "discard") && ($card(owner) != "wonder") } {
          if { $game_state($card(owner)) == $name } {
            set FUNDS_P1 [lreplace $FUNDS_P1 0  0  [expr [lindex $FUNDS_P1 0 ] + [lindex $card(funds) 0]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 1  1  [expr [lindex $FUNDS_P1 1 ] + [lindex $card(funds) 1]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 2  2  [expr [lindex $FUNDS_P1 2 ] + [lindex $card(funds) 2]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 3  3  [expr [lindex $FUNDS_P1 3 ] + [lindex $card(funds) 3]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 4  4  [expr [lindex $FUNDS_P1 4 ] + [lindex $card(funds) 4]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 5  5  [expr [lindex $FUNDS_P1 5 ] + [lindex $card(trade) 0]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 6  6  [expr [lindex $FUNDS_P1 6 ] + [lindex $card(trade) 1]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 7  7  [expr [lindex $FUNDS_P1 7 ] + [lindex $card(depot) 0]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 8  8  [expr [lindex $FUNDS_P1 8 ] + [lindex $card(depot) 1]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 9  9  [expr [lindex $FUNDS_P1 9 ] + [lindex $card(depot) 2]]]
            set FUNDS_P1 [lreplace $FUNDS_P1 10 10 [expr [lindex $FUNDS_P1 10] + [lindex $card(depot) 3]]]
          } else {
            set FUNDS_P2 [lreplace $FUNDS_P2 0  0  [expr [lindex $FUNDS_P2 0 ] + [lindex $card(funds) 0]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 1  1  [expr [lindex $FUNDS_P2 1 ] + [lindex $card(funds) 1]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 2  2  [expr [lindex $FUNDS_P2 2 ] + [lindex $card(funds) 2]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 3  3  [expr [lindex $FUNDS_P2 3 ] + [lindex $card(funds) 3]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 4  4  [expr [lindex $FUNDS_P2 4 ] + [lindex $card(funds) 4]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 5  5  [expr [lindex $FUNDS_P2 5 ] + [lindex $card(trade) 0]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 6  6  [expr [lindex $FUNDS_P2 6 ] + [lindex $card(trade) 1]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 7  7  [expr [lindex $FUNDS_P2 7 ] + [lindex $card(depot) 0]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 8  8  [expr [lindex $FUNDS_P2 8 ] + [lindex $card(depot) 1]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 9  9  [expr [lindex $FUNDS_P2 9 ] + [lindex $card(depot) 2]]]
            set FUNDS_P2 [lreplace $FUNDS_P2 10 10 [expr [lindex $FUNDS_P2 10] + [lindex $card(depot) 3]]]
          }
        }
      }
    }
  }

  # Add wonders bonus (if built)
  for { set i 0 } { $i < 8 } { incr i } {
    if { [llength $game_state(wonders)] > $i } {
      array set wonder [lindex $game_state(wonders) $i]
      if { $wonder(built) == 1 } {
        if { $game_state($wonder(owner)) == $name } {
          # Add bonus for player 1
          set FUNDS_P1 [lreplace $FUNDS_P1 5 5 [expr [lindex $FUNDS_P1 5 ] + [lindex $wonder(trade) 0]]]
          set FUNDS_P1 [lreplace $FUNDS_P1 6 6 [expr [lindex $FUNDS_P1 6 ] + [lindex $wonder(trade) 1]]]
        } else {
          # Add bonus for player 2
          set FUNDS_P2 [lreplace $FUNDS_P2 5 5 [expr [lindex $FUNDS_P2 5 ] + [lindex $wonder(trade) 0]]]
          set FUNDS_P2 [lreplace $FUNDS_P2 6 6 [expr [lindex $FUNDS_P2 6 ] + [lindex $wonder(trade) 1]]]
        }
      }
    }
  }
}

# Determine if the card allows to take a jeton
proc TOOLS_CanTakeJeton { card_lvl card_index name obs } {
  variable game_state
  variable CARDS_P1

  # Observator
  if { $obs == 1 } { return 0 }

  # Get card details
  set j $card_lvl
  array set card [lindex $game_state(cards$j) $card_index]
  if { $card(green) == 0 } { return 0 }

  # Check at least one jeton left
  for { set i 0 } { $i < 5 } { incr i } {
    array set jeton [lindex $game_state(jetons) $i]
    if { $jeton(owner) == "" } { set free 1 }
  }
  if { $free == 0 } { return 0 }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Check if another green card is in the deck
  TOOLS_FillPlayersCards $name $obs
  foreach tcard_p1 $CARDS_P1 {
    array set card_p1 $tcard_p1
    if { $card_p1(green) == $card(green) } { return 1 }
  }
  return 0
}

# Determine if the wonder allows to:
# - Discard a brown card (3)
# - Discard a gray card (4)
# - Rebirth a discarded card (5)
# - Choose 3 jetons (6)
proc TOOLS_GetWonderAction { wonder_index name obs } {
  variable game_state
  variable CARDS_P2

  # Observator
  if { $obs == 1 } { return 0 }

  # Get wonder details
  TOOLS_FillPlayersCards $name $obs
  array set wonder [lindex $game_state(wonders) $wonder_index]

  # Brown
  if { [lindex $wonder(bwar) 0] > 0 } {
    foreach card_t $CARDS_P2 {
      array set card $card_t
      if { $card(color) == "brown" } { return 3 }
    }
  }

  # Gray
  if { [lindex $wonder(bwar) 1] > 0 } {
    foreach card_t $CARDS_P2 {
      array set card $card_t
      if { $card(color) == "gray" } { return 4 }
    }
  }

  # Rebirth
  if { [lindex $wonder(trick) 1] > 0 } { return 5 }

  # Jetons x 3
  if { [lindex $wonder(trick) 0] > 0 } { return 6 }

  # No specific action
  return 1
}

# Determine if a wonder is built by someone
proc TOOLS_IsWonderBuilt {wonder_index} {
  variable game_state

  # Return 1 if the wonder is built
  array set wonder [lindex $game_state(wonders) $wonder_index]
  if { $wonder(built) == 1 } { return 1 }
  return 0
}

# Get the index of the last wonder (-1 if several are not built)
proc TOOLS_GetLastWonder {} {
  variable game_state

  # Return the index of the last wonder not being bought
  set index -1
  set i 0
  foreach wonder_t $game_state(wonders) {
    array set wonder $wonder_t
    if { $wonder(built) == 0 } {
      if { $index != -1 } { return -1 }
      set index $i
    }
    incr i
  }
  return $index
}

# Determine if a jeton is bought
proc TOOLS_IsJetonBought {jeton_name name obs} {
  variable game_state

  # Observator
  if { $obs == 1 } { return 0 }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Search jeton
  foreach jeton_t $game_state(jetons) {
    array set jeton $jeton_t
    if { ($jeton(owner) == $play) && ($jeton(name) == $jeton_name) } {
      return 1
    }
  }
  return 0
}

# Tell if player must decide who start
proc TOOLS_IsNewRound {name} {
  variable game_state

  if { $game_state(newround) == "" } { return 0 }
  if { ($game_state(player_turn) != 29) && ($game_state(player_turn) != 49) } { return 0 }
  if { $game_state(round) > 3 } { return 0 }
  if { $game_state($game_state(newround)) == $name } { return 1 }
  return 0
}

# Get the number of built wonder of a player
proc TOOLS_NbWonderBuilt {name} {
  variable game_state

  if { $name == "ALL" } {
    set p1 [TOOLS_NbWonderBuilt $game_state(player_first)]
    set p2 [TOOLS_NbWonderBuilt $game_state(player_second)]
    if { $p1 > $p2 } { return $p1 }
    return $p2
  }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count them
  set nb 0
  foreach wonder_t $game_state(wonders) {
    array set wonder $wonder_t
    if { ($wonder(built) == 1) &&
         ($wonder(owner) == $play) } {
      incr nb
    }
  }
  return $nb
}

# Get the number of cards of a player of a particular color
proc TOOLS_NbCardsByColor {color name} {
  variable CARDS_P1
  variable game_state

  if { $name == "ALL" } {
    set p1 [TOOLS_NbCardsByColor $color $game_state(player_first)]
    set p2 [TOOLS_NbCardsByColor $color $game_state(player_second)]
    if { $p1 > $p2 } { return $p1 }
    return $p2
  }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count cards
  TOOLS_FillPlayersCards $name 0
  set nb 0
  foreach tcard_p1 $CARDS_P1 {
    array set card_p1 $tcard_p1
    if { $color == "browngray" } {
      if { $card_p1(color) == "brown" } { incr nb }
      if { $card_p1(color) == "gray"  } { incr nb }
    } else {
      if { $card_p1(color) == $color } { incr nb }
    }
  }
  return $nb
}

# Get gold bonus (/3)
proc TOOLS_NbGoldBonus {name} {
  variable game_state

  if { $name == "ALL" } {
    set p1 [TOOLS_NbGoldBonus $game_state(player_first)]
    set p2 [TOOLS_NbGoldBonus $game_state(player_second)]
    if { $p1 > $p2 } { return $p1 }
    return $p2
  }

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count gold
  return [expr $game_state(gold_$play) / 3]
}

# Get the number of PV of cards of a particular color
proc TOOLS_NbPVByColor {color name} {
  variable CARDS_P1
  variable game_state

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count cards
  TOOLS_FillPlayersCards $name 0
  set nb 0
  foreach tcard_p1 $CARDS_P1 {
    array set card_p1 $tcard_p1
    if { $card_p1(color) == $color } {
      if { $color == "purple" } {
        # Case of purple card: add extra PV bonus
        set extra(11) [TOOLS_NbCardsByColor "browngray" "ALL"]
        set extra(12) [TOOLS_NbCardsByColor "yellow"    "ALL"]
        set extra(13) [TOOLS_NbCardsByColor "blue"      "ALL"]
        set extra(14) [TOOLS_NbCardsByColor "green"     "ALL"]
        set extra(15) [TOOLS_NbCardsByColor "red"       "ALL"]
        set extra(16) [TOOLS_NbWonderBuilt              "ALL"]
        set extra(17) [TOOLS_NbGoldBonus                "ALL"]
        if { $card_p1(extra) == 11 } { set nb [expr $nb + ($extra(11) * 1)] }
        if { $card_p1(extra) == 12 } { set nb [expr $nb + ($extra(12) * 1)] }
        if { $card_p1(extra) == 13 } { set nb [expr $nb + ($extra(13) * 1)] }
        if { $card_p1(extra) == 14 } { set nb [expr $nb + ($extra(14) * 1)] }
        if { $card_p1(extra) == 15 } { set nb [expr $nb + ($extra(15) * 1)] }
        if { $card_p1(extra) == 16 } { set nb [expr $nb + ($extra(16) * 2)] }
        if { $card_p1(extra) == 17 } { set nb [expr $nb + ($extra(17) * 1)] }
      } else {
        set nb [expr $nb + [lindex $card_p1(bonus) 1]]
      }
    }
  }
  return $nb
}

# Get the number of PV of built wonders of a player
proc TOOLS_NbPVWonderBuilt {name} {
  variable game_state

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count them
  set nb 0
  foreach wonder_t $game_state(wonders) {
    array set wonder $wonder_t
    if { ($wonder(built) == 1) &&
         ($wonder(owner) == $play) } {
      set nb [expr $nb + [lindex $wonder(bonus) 2]]
    }
  }
  return $nb
}

# Get the number of PV of jetons of a player
proc TOOLS_NbPVJetons {name} {
  variable game_state

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  # Count them
  set nb 0
  set nb_jetons 0
  set math 0
  foreach jeton_t $game_state(jetons) {
    array set jeton $jeton_t
    if { $jeton(owner) == $play } {
      set nb [expr $nb + [lindex $jeton(bonus) 1]]
      if { $jeton(item) == 5 } {
        set math 1
      }
      incr nb_jetons
    }
  }
  # Add mathematics effect
  set nb [expr $nb + ($math * $nb_jetons * 3)]
  return $nb
}

# Get the number of PV of war of a player
proc TOOLS_NbWarBonus {name} {
  variable game_state

  # Get player
  set play "player_first"
  if { $name == $game_state(player_second) } { set play "player_second" }

  if { $play == "player_first" } {
    if { ($game_state(warrior) >= 1) && ($game_state(warrior) <= 2) } {
      return 2
    } elseif { ($game_state(warrior) >= 3) && ($game_state(warrior) <= 5) } {
      return 5
    } elseif { ($game_state(warrior) >= 6) && ($game_state(warrior) <= 9) } {
      return 10
    }
  } elseif { $play == "player_second" } {
    if { ($game_state(warrior) <= -1) && ($game_state(warrior) >= -2) } {
      return 2
    } elseif { ($game_state(warrior) <= -3) && ($game_state(warrior) >= -5) } {
      return 5
    } elseif { ($game_state(warrior) <= -6) && ($game_state(warrior) >= -9) } {
      return 10
    }
  }
  return 0
}

# Compute the total number of PV of a player
proc TOOLS_NbPV {name} {
  variable game_state

  # Count
  if { ($game_state(player_first)  == "") &&
       ($game_state(player_second) == "") } { return 0 }
  set pv [expr [TOOLS_NbPVByColor "blue"   $name] + \
               [TOOLS_NbPVByColor "green"  $name] + \
               [TOOLS_NbPVByColor "yellow" $name] + \
               [TOOLS_NbPVByColor "purple" $name] + \
               [TOOLS_NbPVWonderBuilt      $name] + \
               [TOOLS_NbPVJetons           $name] + \
               [TOOLS_NbGoldBonus          $name] + \
               [TOOLS_NbWarBonus           $name] ]
  return $pv
}

