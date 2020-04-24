#!/usr/bin/tclsh

# Tools used to check if an action is possible
source $SCRIPT_PATH/client/tools.tcl

# Which commands shall be understood by our protocol
set commands {
  Disconnect
  NewGame
  JoinGame
  SendChatMessage
  SelectWonder
  TakeCard
  DiscardCard
  BuildWonder
  SaveGame
  LoadGame
  RefreshGame
  StartRound
  TestConnexion
  PlayBack
  PlayNext
  KillYou
}

# Kill server
proc KillYou {} {
  variable forever

  set forever 0
  return ""
}

# TestConnexion
proc TestConnexion {} {}

# Start a new game (before the end of the previous one)
proc NewGame {{msg 1}} {
  variable game_state

  set game_state(player_turn) 0
  set game_state(wonders)     {}
  set game_state(jetons)      {}
  set game_state(jeton3)      {}
  set game_state(cards1)      {}
  set game_state(cards2)      {}
  set game_state(cards3)      {}
  set game_state(warrior)     0
  set game_state(round)       0
  set game_state(replay)      0
  set game_state(newround)    ""
  set game_state(win_science) ""
  set game_state(win_war)     ""
  set game_state(malus_player_first)  {1 1}
  set game_state(malus_player_second) {1 1}
  set game_state(gold_player_first)   7
  set game_state(gold_player_second)  7
  set game_state(action_jeton)   -1
  set game_state(action_wonder)  -1
  set game_state(action_wcard)   {-1 -1}
  set game_state(action_warrior) 0
  set game_state(action_discard) -1
  set game_state(action_discard_owner) ""
  set game_state(action_card)    ""
  if { $msg == 1 } {
    set game_state(player_turn) 1
    ManageTurn
    return "GUI_Dialog {7 Wonders} {Nouvelle partie demarree}"
  }
}

# Game initial state
array set game_state ""
set game_state(player_first)  ""
set game_state(player_second) ""
set game_state(player_list)   {}
set game_state(play)          "player_first"
set game_state(version_server_minor) "$SERVER_VERSION_MINOR"
set game_state(version_server_major) "$SERVER_VERSION_MAJOR"
NewGame 0

# Save a game
proc SaveGame {{gamefile "game.save"}} {
  variable SCRIPT_PATH
  variable game_state

  set fp [open "$SCRIPT_PATH/save/$gamefile" w]
  puts $fp [array get game_state]
  close $fp
  return "GUI_Dialog {7 Wonders} {Partie sauvegardee}"
}

# Load a game
proc LoadGame {{gamefile "game.save"}} {
  variable SCRIPT_PATH
  variable SERVER_VERSION_MAJOR
  variable SERVER_VERSION_MINOR
  variable game_state

  set player_list   $game_state(player_list)
  set player_first  $game_state(player_first)
  set player_second $game_state(player_second)
  if { [catch { set fp [open "$SCRIPT_PATH/save/$gamefile" r] } ] } {
    return
  }
  array set game_state [read $fp]
  close $fp
  set game_state(player_list) $player_list
  if { ($game_state(player_second) == $player_first ) ||
       ($game_state(player_first)  == $player_second) } {
    set game_state(player_second) $player_first
    set game_state(player_first)  $player_second
  } else {
    set game_state(player_first)  $player_first
    set game_state(player_second) $player_second
  }
  set game_state(version_server_major) "$SERVER_VERSION_MAJOR"
  set game_state(version_server_minor) "$SERVER_VERSION_MINOR"
  # No discard other card mouvement
  set game_state(action_discard) -2
  # Load it
  ManageTurn 0
  if { $gamefile == "game.save" } {
    return "GUI_Dialog {7 Wonders} {Partie chargee}"
  } else {
    return ""
  }
}

# Back to previous turn
proc PlayBack {} {
  variable game_state

  # Load previous turn
  set turn [expr $game_state(player_turn) - 1]
  LoadGame "turn$turn.save"
}

# Back to next turn
proc PlayNext {} {
  variable game_state

  # Load previous turn
  set turn [expr $game_state(player_turn) + 1]
  LoadGame "turn$turn.save"
}

proc SaveTurn {} {
  variable game_state

  # Save turn
  set turn $game_state(player_turn)
  SaveGame "turn$turn.save"
  incr turn
  catch { file delete "$SCRIPT_PATH/save/turn$turn.save" }
}

# Refresh a game
proc RefreshGame {} {
  variable game_state

  # Send game update
  puts "RefreshGame for all players"
  foreach player $game_state(player_list) {
    # Send new code
    set tls_socket [lindex $player 2]
    slaveServer::SendSourceCode $tls_socket
  }

  # No discard other card mouvement
  set game_state(action_discard) -2
  UpdateGameState
}

# Send message to all players
proc SendMessageToAll {msg} {
  variable game_state

  # Send message to all players
  foreach player $game_state(player_list) {
    set tls_socket [lindex $player 2]
    catch { puts $tls_socket "$msg" }
    puts stderr [regsub -all -line ^ $msg "$tls_socket < "]
  }
}

# Add bonus of cards (bonus+extra)
proc AddCardBonus {card_t} {
  variable game_state
  upvar 1 state state

  # Add card gold and PV 
  array set card $card_t
  if { $state(name) == $game_state(player_first)  } { set play "player_first"  }
  if { $state(name) == $game_state(player_second) } { set play "player_second" }
  set game_state(gold_$play) [expr $game_state(gold_$play) + [lindex $card(bonus) 0]]

  # Add warriors
  set warrior_joker [TOOLS_IsJetonBought "STRATEGIE" $state(name) $state(obs)]
  set warrior [lindex $card(bonus) 2]
  if { $warrior > 0 } {
    if { $play == "player_first"  } {
      set game_state(warrior) [expr $game_state(warrior) + ($warrior + $warrior_joker)]
    } else {
      set game_state(warrior) [expr $game_state(warrior) - ($warrior + $warrior_joker)]
    }
    set game_state(action_warrior) 1
  }

  # Add extra gold bonus
  set extra(1) [TOOLS_NbCardsByColor "brown"  $state(name)]
  set extra(2) [TOOLS_NbCardsByColor "gray"   $state(name)]
  set extra(3) [TOOLS_NbCardsByColor "yellow" $state(name)]
  set extra(4) [TOOLS_NbCardsByColor "red"    $state(name)]
  set extra(5) [TOOLS_NbWonderBuilt           $state(name)]
  set extra(11) [TOOLS_NbCardsByColor "browngray" "ALL"]
  set extra(12) [TOOLS_NbCardsByColor "yellow"    "ALL"]
  set extra(13) [TOOLS_NbCardsByColor "blue"      "ALL"]
  set extra(14) [TOOLS_NbCardsByColor "green"     "ALL"]
  set extra(15) [TOOLS_NbCardsByColor "red"       "ALL"]
  set extra(16) [TOOLS_NbWonderBuilt              "ALL"]
  set extra(17) [TOOLS_NbGoldBonus                "ALL"]
  set bonus 0
  if { $card(extra) == 1  } { set bonus [expr $extra(1)  * 2] }
  if { $card(extra) == 2  } { set bonus [expr $extra(2)  * 3] }
  if { $card(extra) == 3  } { set bonus [expr $extra(3)  * 1] }
  if { $card(extra) == 4  } { set bonus [expr $extra(4)  * 1] }
  if { $card(extra) == 5  } { set bonus [expr $extra(5)  * 2] }
  if { $card(extra) == 11 } { set bonus [expr $extra(11) * 1] }
  if { $card(extra) == 12 } { set bonus [expr $extra(12) * 1] }
  if { $card(extra) == 13 } { set bonus [expr $extra(13) * 1] }
  if { $card(extra) == 14 } { set bonus [expr $extra(14) * 1] }
  if { $card(extra) == 15 } { set bonus [expr $extra(15) * 1] }
  if { $card(extra) == 16 } { set bonus [expr $extra(16) * 2] }
  if { $card(extra) == 17 } { set bonus [expr $extra(17) * 1] }
  set game_state(gold_$play) [expr $game_state(gold_$play) + $bonus]
}

# Incates who must start the round
proc StartRound {first_player} {
  variable game_state
  upvar 1 state state

  if { $state(name) == $game_state(player_first)  } { set play "player_first"  ; set other "player_second" }
  if { $state(name) == $game_state(player_second) } { set play "player_second" ; set other "player_first"  }
  if { [TOOLS_IsNewRound $state(name)] == 1 } {
    if { $first_player == "me" } {
      set game_state(play) $play
      set game_state(newround) ""
    } else {
      set game_state(play) $other
      set game_state(newround) ""
    }
  }
  UpdateGameState
}

# Manage warrior
proc ManageWarrior {} {
  variable game_state
  variable CARDS_P1
  variable CARDS_P2
  upvar 1 state state

  # Manage warrior malus
  if { ($game_state(warrior) >= 3) && ([lindex $game_state(malus_player_second) 0] == 1) } {
    set game_state(malus_player_second) [lreplace $game_state(malus_player_second) 0 0 0]
    set game_state(gold_player_second) [expr $game_state(gold_player_second) - 2]
    if { $game_state(gold_player_second) < 0 } { set game_state(gold_player_second) 0 }
    SendMessageToAll "CHAT_DisplayMessage {$game_state(player_second) a perdu 2 pieces d'or au combat} {black}"
  }
  if { ($game_state(warrior) >= 6) && ([lindex $game_state(malus_player_second) 1] == 1) } {
    set game_state(malus_player_second) [lreplace $game_state(malus_player_second) 1 1 0]
    set game_state(gold_player_second) [expr $game_state(gold_player_second) - 5]
    if { $game_state(gold_player_second) < 0 } { set game_state(gold_player_second) 0 }
    SendMessageToAll "CHAT_DisplayMessage {$game_state(player_second) a perdu 5 pieces d'or au combat} {black}"
  }
  if { ($game_state(warrior) <= -3) && ([lindex $game_state(malus_player_first) 0] == 1) } {
    set game_state(malus_player_first) [lreplace $game_state(malus_player_first) 0 0 0]
    set game_state(gold_player_first) [expr $game_state(gold_player_first) - 2]
    if { $game_state(gold_player_first) < 0 } { set game_state(gold_player_first) 0 }
    SendMessageToAll "CHAT_DisplayMessage {$game_state(player_first) a perdu 2 pieces d'or au combat} {black}"
  }
  if { ($game_state(warrior) <= -6) && ([lindex $game_state(malus_player_first) 1] == 1) } {
    set game_state(malus_player_first) [lreplace $game_state(malus_player_first) 1 1 0]
    set game_state(gold_player_first) [expr $game_state(gold_player_first) - 5]
    if { $game_state(gold_player_first) < 0 } { set game_state(gold_player_first) 0 }
    SendMessageToAll "CHAT_DisplayMessage {$game_state(player_first) a perdu 5 pieces d'or au combat} {black}"
  }

  # Test warrior victory
  if { $game_state(warrior) >=  9 } {
    set game_state(round) 4
    set game_state(win_war) "player_first"
    SendMessageToAll "GUI_Dialog {Fin de partie} {$game_state(player_first) a vaincu par la guerre!}"
  }
  if { $game_state(warrior) <= -9 } {
    set game_state(round) 4
    set game_state(win_war) "player_second"
    SendMessageToAll "GUI_Dialog {Fin de partie} {$game_state(player_second) a vaincu par la guerre!}"
  }

  # Test science victory
  set nb1 0
  set nb2 0
  TOOLS_FillPlayersCards $game_state(player_first) 0
  set green_list {0}
  foreach card_t $CARDS_P1 {
    array set card $card_t
    if { [lsearch -exact $green_list $card(green)] == -1 } {
      lappend green_list $card(green)
      incr nb1
    }
  }
  set green_list {0}
  foreach card_t $CARDS_P2 {
    array set card $card_t
    if { [lsearch -exact $green_list $card(green)] == -1 } {
      lappend green_list $card(green)
      incr nb2
    }
  }
  if { [TOOLS_IsJetonBought "LOI" $game_state(player_first)  $state(obs)] == 1 } { incr nb1 }
  if { [TOOLS_IsJetonBought "LOI" $game_state(player_second) $state(obs)] == 1 } { incr nb2 }
  if { $nb1 >= 6 } {
    set game_state(round) 4
    set game_state(win_science) "player_first"
    SendMessageToAll "GUI_Dialog {Fin de partie} {$game_state(player_first) a vaincu par la science!}"
  }
  if { $nb2 >= 6 } {
    set game_state(round) 4
    set game_state(win_science) "player_second"
    SendMessageToAll "GUI_Dialog {Fin de partie} {$game_state(player_second) a vaincu par la science!}"
  }
}

# Build a wonder
proc BuildWonder {index_card index_wonder {index_discard -1} {rebirth_lvl -1} {rebirth_num -1} {index_jeton -1}} {
  variable game_state
  variable CARDS_P2
  upvar 1 state state

  if { $state(obs) == 1 } {
    return "GUI_Dialog {Erreur Interne} {Un observateur ne peut pas construire de merveilles}"
  }
  if { ([TOOLS_IsWonderSelectable $state(name) $index_wonder] == 1) &&
       ([TOOLS_IsCardSelectable $index_card] == 1) &&
       ([TOOLS_GetLastWonder ] == -1) &&
       ([TOOLS_NbWonderBuilt $state(name)] < 4) } {
    set price [TOOLS_GetWonderPrice $index_wonder $state(name) $state(obs)]
    if { $state(name) == $game_state(player_first)  } { set play "player_first"  ; set other "player_second" }
    if { $state(name) == $game_state(player_second) } { set play "player_second" ; set other "player_first"  }
    if { $price <= $game_state(gold_$play) } {
      # Save previous turn
      SaveTurn

      # Wonder Selection
      set game_state(action_warrior) 0
      set game_state(action_discard) -1
      set game_state(action_card)    ""
      set game_state(action_wonder)  $index_wonder
      set game_state(action_wcard)   "$game_state(round) $index_card"
      set game_state(action_jeton)   -1

      # Pay the price for the wonder
      set game_state(gold_$play) [expr $game_state(gold_$play) - $price]

      # Set the wonder as built
      array set wonder [lindex $game_state(wonders) $index_wonder]
      set wonder(built) 1
      set game_state(wonders) [lreplace $game_state(wonders) $index_wonder $index_wonder [array get wonder]]

      # Put the card under the wonder
      set j $game_state(round)
      array set card [lindex $game_state(cards$j) $index_card]
      set card(owner) "wonder"
      set game_state(cards$j) [lreplace $game_state(cards$j) $index_card $index_card [array get card]]

      # With economie, pay price to the other player (only commerce)
      if { ($price > 0) && ([TOOLS_IsJetonBought "ECONOMIE" $game_state($other) 0] == 1) } {
        set game_state(gold_$other) [expr $game_state(gold_$other) + $price]
      }

      # Add gold
      set game_state(gold_$play)  [expr $game_state(gold_$play)  + [lindex $wonder(bonus) 0]]
      set game_state(gold_$other) [expr $game_state(gold_$other) - [lindex $wonder(bonus) 1]]
      if { $game_state(gold_$other) < 0 } { set game_state(gold_$other) 0 }

      # Discard other card
      if { $index_discard >= 0 } {
        TOOLS_FillPlayersCards $state(name) 0
        array set discard_card [lindex $CARDS_P2 $index_discard]
        if { ([TOOLS_IsBrownCardSelectable $state(name) $index_discard] == 1) ||
             ([TOOLS_IsGrayCardSelectable  $state(name) $index_discard] == 1) } {
          set game_state(action_discard) $index_discard
          set game_state(action_discard_owner) $discard_card(owner)
          set discard_card(owner) "discard"
          # Replace it
          TOOLS_ReplaceCard [array get discard_card]

          # Send message to all players
          SendMessageToAll "CHAT_DisplayMessage {$state(name) a detruit la carte [string tolower $discard_card(name)] du joueur adverse} {black}"
        }
      }

      # Add warriors
      if { $play == "player_first"  } {
        set game_state(warrior) [expr $game_state(warrior) + [lindex $wonder(bwar) 2]]
      } else {
        set game_state(warrior) [expr $game_state(warrior) - [lindex $wonder(bwar) 2]]
      }
      if { [lindex $wonder(bwar) 2] > 0 } {
        set game_state(action_warrior) 1
      }

      # Manage warrior
      ManageWarrior

      # Next turn
      set game_state(player_turn) [expr $game_state(player_turn) + 1]

      # Send message to all players
      SendMessageToAll "CHAT_DisplayMessage {$state(name) a construit la merveille [string tolower $wonder(name)]} {black}"

      # Manage next turn
      if { ([lindex $wonder(bonus) 3] > 0) || ([TOOLS_IsJetonBought "THEOLOGIE" $state(name) $state(obs)] == 1) } {
        ManageTurn 0
      } else {
        ManageTurn
      }

      # Build a discarded card
      if { ($rebirth_num >= 0) && ($rebirth_lvl >= 0) && ([lindex $wonder(trick) 1] > 0) } {
        array set rebirth_card [lindex $game_state(cards$rebirth_lvl) $rebirth_num]
        if { $rebirth_card(owner) == "discard" } {
          set rebirth_card(owner) $play
          # Replace it
          TOOLS_ReplaceCard [array get rebirth_card]
          set game_state(action_card) $rebirth_card(name)

          # Add cards bonus (bonus+extra)
          AddCardBonus [array get rebirth_card]

          # Send message to all players
          SendMessageToAll "CHAT_DisplayMessage {$state(name) a recupere la carte [string tolower $rebirth_card(name)] de la defausse} {black}"

          # Test green cards
          if { ([TOOLS_IsJetonSelectable $index_jeton] == 1) &&
               ([TOOLS_CanTakeJeton $rebirth_lvl $rebirth_num $state(name) $state(obs)] == 1) &&
               ([lindex $wonder(trick) 1] > 0) } {
            # Add jeton bonus
            array set jeton [lindex $game_state(jetons) $index_jeton]
            set game_state(gold_$play) [expr $game_state(gold_$play) + [lindex $jeton(bonus) 0]]

            # Take the jeton
            set jeton(owner) $play
            set game_state(jetons) [lreplace $game_state(jetons) $index_jeton $index_jeton [array get jeton]]
            set game_state(action_jeton) $index_jeton

            # Send message to all players
            SendMessageToAll "CHAT_DisplayMessage {$state(name) a recupere le jeton [string tolower $jeton(name)]} {black}"
          }
        }
      }

      # Build a jeton
      if { ($index_jeton >= 0) && ([lindex $wonder(trick) 0] > 0) } {
        array set jeton3 [lindex $game_state(jeton3) $index_jeton]

        # Add jeton to player deck
        set jeton3(owner) $play
        lappend game_state(jetons) [array get jeton3]
        set game_state(action_jeton) 5

        # Add jeton bonus
        set game_state(gold_$play) [expr $game_state(gold_$play) + [lindex $jeton3(bonus) 0]]

        # Send message to all players
        SendMessageToAll "CHAT_DisplayMessage {$state(name) a recupere le jeton [string tolower $jeton3(name)]} {black}"
      }

      # Manage warrior
      ManageWarrior

      # Update without changing player
      ManageTurn 0
    } else {
      return "GUI_Dialog {Action impossible} {Stock d'or insuffisant}"
    }
  } else {
    return "GUI_Dialog {Erreur Interne} {Carte ou merveille selectionnee invalide}"
  }
}

# Take a card
proc TakeCard {index_card index_jeton} {
  variable game_state
  upvar 1 state state

  if { $state(obs) == 1 } {
    return "GUI_Dialog {Erreur Interne} {Un observateur ne peut pas acheter de cartes}"
  }
  if { [TOOLS_IsCardSelectable $index_card] == 1 } {
    set price [TOOLS_GetCardPrice $index_card $state(name) $state(obs)]
    set chain 0
    if { $price == -1 } {
      set chain 1
      set price 0
    }
    if { $state(name) == $game_state(player_first)  } { set play "player_first"  ; set other "player_second" }
    if { $state(name) == $game_state(player_second) } { set play "player_second" ; set other "player_first"  }
    if { $price <= $game_state(gold_$play) } {
      # Save previous turn
      SaveTurn

      # Pay the price for the card
      set game_state(gold_$play) [expr $game_state(gold_$play) - $price]

      # Add the card to the player deck
      set j $game_state(round)
      array set card [lindex $game_state(cards$j) $index_card]
      set card(owner) $play
      set game_state(cards$j) [lreplace $game_state(cards$j) $index_card $index_card [array get card]]

      # Card Selection
      set game_state(action_warrior) 0
      set game_state(action_discard) -1
      set game_state(action_card)    "$card(name)"
      set game_state(action_wonder)  -1
      set game_state(action_wcard)   "$game_state(round) $index_card"
      set game_state(action_jeton)   -1

      # With economie, pay price to the other player (only commerce)
      if { ($price > 0) && ([TOOLS_IsJetonBought "ECONOMIE" $game_state($other) 0] == 1) } {
        set game_state(gold_$other) [expr $game_state(gold_$other) + $price - [lindex $card(price) 5]]
      }

      # Add cards bonus (bonus+extra)
      AddCardBonus [array get card]

      # Add gold if chain and wonder
      if { ($chain == 1) && ([TOOLS_IsJetonBought "URBANISME" $state(name) $state(obs)] == 1) } {
        set game_state(gold_$play) [expr $game_state(gold_$play) + 4]
      }

      # Send message to all players
      SendMessageToAll "CHAT_DisplayMessage {$state(name) a achete la carte [string tolower $card(name)]} {black}"

      # Test green cards
      if { ([TOOLS_IsJetonSelectable $index_jeton] == 1) &&
           ([TOOLS_CanTakeJeton $game_state(round) $index_card $state(name) $state(obs)] == 1) } {
        # Add jeton bonus
        array set jeton [lindex $game_state(jetons) $index_jeton]
        set game_state(gold_$play) [expr $game_state(gold_$play) + [lindex $jeton(bonus) 0]]

        # Take the jeton
        set jeton(owner) $play
        set game_state(jetons) [lreplace $game_state(jetons) $index_jeton $index_jeton [array get jeton]]
        set game_state(action_jeton) $index_jeton

        # Send message to all players
        SendMessageToAll "CHAT_DisplayMessage {$state(name) a recupere le jeton [string tolower $jeton(name)]} {black}"
      }

      # Manage warrior
      ManageWarrior

      # Next turn
      set game_state(player_turn) [expr $game_state(player_turn) + 1]

      # Manage next turn
      ManageTurn
    } else {
      return "GUI_Dialog {Action impossible} {Stock d'or insuffisant}"
    }
  } else {
    return "GUI_Dialog {Erreur Interne} {Carte selectionnee invalide}"
  }
}

# Discard a card
proc DiscardCard {index} {
  variable CARDS_P1
  variable game_state
  upvar 1 state state

  if { $state(obs) == 1 } {
    return "GUI_Dialog {Erreur Interne} {Un observateur ne peut pas defausser de cartes}"
  }
  if { [TOOLS_IsCardSelectable $index] == 1 } {
    # Save previous turn
    SaveTurn

    # Discard
    set game_state(action_warrior) 0
    set game_state(action_discard) 1
    set game_state(action_card)    ""
    set game_state(action_wonder)  -1
    set game_state(action_wcard)   "$game_state(round) $index"
    set game_state(action_jeton)   -1

    # Add money
    if { $state(name) == $game_state(player_first)  } { set play "player_first"  }
    if { $state(name) == $game_state(player_second) } { set play "player_second" }
    TOOLS_FillPlayersCards $state(name) $state(obs)
    set nb_yellow 0
    for { set i 0 } { $i < [llength $CARDS_P1] } { incr i } {
      array set card [lindex $CARDS_P1 $i]
      if { $card(color) == "yellow" } {
        incr nb_yellow
      }
    }
    set game_state(gold_$play) [expr $game_state(gold_$play) + 2 + $nb_yellow]

    # Discard the card
    set j $game_state(round)
    array set card [lindex $game_state(cards$j) $index]
    set card(owner) "discard"
    set game_state(cards$j) [lreplace $game_state(cards$j) $index $index [array get card]]
    set game_state(action_card) $card(name)

    # Next turn
    set game_state(player_turn) [expr $game_state(player_turn) + 1]

    # Send message to all players
    SendMessageToAll "CHAT_DisplayMessage {$state(name) a defausse la carte [string tolower $card(name)]} {black}"

    # Manage next turn
    ManageTurn
  } else {
    return "GUI_Dialog {Erreur Interne} {Carte selectionnee invalide}"
  }
}

# Select a wonder
proc SelectWonder {num} {
  variable game_state
  upvar 1 state state

  if { ($num >= 0) && ($num <= 3) } {
    if { $game_state(player_turn) > 4 } { set num [expr $num + 4] }
    array set wonder [lindex $game_state(wonders) $num]
    if { $wonder(owner) == "" } {
      if { ($state(name) == $game_state(player_first))  && ($game_state(play) == "player_first" ) } { set wonder(owner) "player_first"  }
      if { ($state(name) == $game_state(player_second)) && ($game_state(play) == "player_second") } { set wonder(owner) "player_second" }
      if { $wonder(owner) == "" } {
        return "GUI_Dialog {Erreur Interne} {Observateur (TODO) ou erreur de joueur}"
      } else {
        # Save previous turn
        SaveTurn

        # Select the wonder
        set game_state(wonders) [lreplace $game_state(wonders) $num $num [array get wonder]]

        # Next turn
        set game_state(player_turn) [expr $game_state(player_turn) + 1]

        # Send message to all players
        SendMessageToAll "CHAT_DisplayMessage {$state(name) a construit la merveille [string tolower $wonder(name)]} {black}"

        # Manage next turn
        ManageTurn
      }
    } else {
      return "GUI_Dialog {Erreur Interne} {Merveille deja prise par $game_state($wonder(owner))}"
    }
  } else {
    return "GUI_Dialog {Erreur Interne} {Indice de merveille $num en erreur}"
  }
}

# Send a chat message
proc SendChatMessage {message} {
  variable game_state
  upvar 1 state state

  # Get player color
  if { $game_state(player_first) == $state(name) } {
    set color "DarkBlue"
  } elseif { $game_state(player_second) == $state(name) } {
    set color "DarkGreen"
  } else {
    set color "DarkGray"
  }

  # Send message to all players
  SendMessageToAll "CHAT_DisplayMessage {($state(name)) $message} {$color}"
}

# perform actions depending on the turn
proc ManageTurn {{update_turn 1}} {
  variable game_state
  variable WONDERS
  variable SCRIPT_PATH
  upvar 1 state state

  # Select 8 wonders if not done
  if { [llength $game_state(wonders)] == 0 } {
    source $SCRIPT_PATH/server/cfg_wonders.tcl
    for { set i 0 } { $i < 8 } { incr i } {
      set nb_wonders [llength $WONDERS]
      set random [expr int(rand()*$nb_wonders)]
      lappend game_state(wonders) [lindex $WONDERS $random]
      set WONDERS [lreplace $WONDERS $random $random]
    }
  }

  # Select 5 jetons if not done (and 3 for wonder)
  if { [llength $game_state(jetons)] == 0 } {
    source $SCRIPT_PATH/server/cfg_jetons.tcl
    for { set i 0 } { $i < 5 } { incr i } {
      set nb_jetons [llength $JETONS]
      set random [expr int(rand()*$nb_jetons)]
      lappend game_state(jetons) [lindex $JETONS $random]
      set JETONS [lreplace $JETONS $random $random]
    }
    for { set i 0 } { $i < 3 } { incr i } {
      set nb_jetons [llength $JETONS]
      set random [expr int(rand()*$nb_jetons)]
      lappend game_state(jeton3) [lindex $JETONS $random]
      set JETONS [lreplace $JETONS $random $random]
    }
  }

  # Select 20 cards#1 if not done
  if { [llength $game_state(cards1)] == 0 } {
    source $SCRIPT_PATH/server/cfg_cards1.tcl
    for { set i 0 } { $i < 20 } { incr i } {
      set nb_cards [llength $CARDS1]
      set random [expr int(rand()*$nb_cards)]
      lappend game_state(cards1) [lindex $CARDS1 $random]
      set CARDS1 [lreplace $CARDS1 $random $random]
    }
  }

  # Select 20 cards#2 if not done
  if { [llength $game_state(cards2)] == 0 } {
    source $SCRIPT_PATH/server/cfg_cards2.tcl
    for { set i 0 } { $i < 20 } { incr i } {
      set nb_cards [llength $CARDS2]
      set random [expr int(rand()*$nb_cards)]
      lappend game_state(cards2) [lindex $CARDS2 $random]
      set CARDS2 [lreplace $CARDS2 $random $random]
    }
  }

  # Select 17 cards#3 and 3 cards#4 if not done
  if { [llength $game_state(cards3)] == 0 } {
    set deck {}
    source $SCRIPT_PATH/server/cfg_cards3.tcl
    for { set i 0 } { $i < 17 } { incr i } {
      set nb_cards [llength $CARDS3]
      set random [expr int(rand()*$nb_cards)]
      lappend deck [lindex $CARDS3 $random]
      set CARDS3 [lreplace $CARDS3 $random $random]
    }
    source $SCRIPT_PATH/server/cfg_cards4.tcl
    for { set i 0 } { $i < 3 } { incr i } {
      set nb_cards [llength $CARDS4]
      set random [expr int(rand()*$nb_cards)]
      lappend deck [lindex $CARDS4 $random]
      set CARDS4 [lreplace $CARDS4 $random $random]
    }
    # Mix them
    for { set i 0 } { $i < 20 } { incr i } {
      set nb_cards [llength $deck]
      set random [expr int(rand()*$nb_cards)]
      lappend game_state(cards3) [lindex $deck $random]
      set deck [lreplace $deck $random $random]
    }
  }

  # The player not playing must wait
  # 8 first turns: ABBA-BAAB
  if { $game_state(player_turn) == 1 } { set game_state(play) "player_first"  }
  if { $game_state(player_turn) == 2 } { set game_state(play) "player_second" }
  if { $game_state(player_turn) == 3 } { set game_state(play) "player_second" }
  if { $game_state(player_turn) == 4 } { set game_state(play) "player_first"  }
  if { $game_state(player_turn) == 5 } { set game_state(play) "player_second" }
  if { $game_state(player_turn) == 6 } { set game_state(play) "player_first"  }
  if { $game_state(player_turn) == 7 } { set game_state(play) "player_first"  }
  if { $game_state(player_turn) == 8 } { set game_state(play) "player_second" }
  if { $game_state(player_turn) == 9 } { set game_state(play) "player_first"  }
  if { $update_turn == 1 } {
    # Next turns: invert player (except on a replay)
    if { $game_state(player_turn) > 9 } { 
      if { $game_state(replay) == 0 } {
        if { $game_state(play) == "player_first" } {
          set game_state(play) "player_second"
        } else {
          set game_state(play) "player_first"
        }
      } else {
        set game_state(replay) 0
      }
    }

    # Round 29/49: Determine first player
    if { ($game_state(player_turn) == 29) || ($game_state(player_turn) == 49) } {
      set game_state(play) ""
      if { $game_state(warrior) > 0 } { set game_state(newround) "player_second" }
      if { $game_state(warrior) < 0 } { set game_state(newround) "player_first"  }
      if { $game_state(warrior) == 0 } {
        catch {
          if { $state(name) == $game_state(player_first)  } { set game_state(newround) "player_first"  }
          if { $state(name) == $game_state(player_second) } { set game_state(newround) "player_second" }
        }
      }
    }
  }

  # After round first player selection, discarded card don't move
  if { ($game_state(player_turn) == 29) || ($game_state(player_turn) == 49) } {
    if { $game_state(play) != "" } {
      set game_state(action_discard) -2
    }
  }

  # Manage next round
  if { $game_state(round) < 4 } {
    set game_state(round) 0
    if { ($game_state(player_turn) > 8 ) && ($game_state(player_turn) <= 28) } { set game_state(round) 1 }
    if { ($game_state(player_turn) > 28) && ($game_state(player_turn) <= 48) } { set game_state(round) 2 }
    if { ($game_state(player_turn) > 48) && ($game_state(player_turn) <= 68) } { set game_state(round) 3 }
    if { ($game_state(player_turn) > 68)                                     } { set game_state(round) 4 }
  }

  # Update game state
  UpdateGameState
}

# Send the game state to all clients
proc UpdateGameState {} {
  variable game_state

  foreach player $game_state(player_list) {
    set tls_socket [lindex $player 2]
    set cmd "GUI_UpdateGameState {[array get game_state]}"
    catch { puts $tls_socket "$cmd" }
    puts stderr [regsub -all -line ^ $cmd "$tls_socket < "]
  }
}

# Check clients connectivity
proc CheckConnectivity {} {
  variable game_state

  foreach player $game_state(player_list) {
    set tls_socket [lindex $player 2]
    if { [eof $tls_socket] } { Disconnect $tls_socket [lindex $player 0] }
  }
}

# Command used to join a game
proc JoinGame {name obs} {
  variable game_state
  upvar 1 state state

  # Check clients connectivity
  CheckConnectivity

  # Check maximum number of clients
  set nb_clients [llength $game_state(player_list)]
  if { $nb_clients > 10 } {
    return "GUI_Dialog {Erreur de connexion} {Trop de joueurs connectes!}"
  }

  # Get number of players
  set nb_players 0
  set players {}
  foreach player $game_state(player_list) {
    if { [lindex $player 0] == $name } {
      # Disconnect the older one and start again
      Disconnect [lindex $player 2] [lindex $player 0]
      JoinGame $name $obs
      return
    }
    if { [lindex $player 1] == 0 } {
      incr nb_players
      lappend players [lindex $player 0]
    }
  }

  # If both players are already connected:
  if { ($nb_players >= 2) && ($obs == 0) } {
    # Update game state
    UpdateGameState

    # Display an error
    return "GUI_Dialog {Erreur de connexion} {Les deux joueurs sont deja connectes, essayez en observateur!}"
  }

  # Add player
  lappend game_state(player_list) [list $name $obs $state(socket)]
  set state(name) $name
  set state(obs)  $obs
  if { $obs == 0 } {
    incr nb_players
    lappend players $name
  }
  # If 2 real players are here now:
  if { $nb_players >= 2 } {
    # Select first player if necessary (random)
    if { $game_state(player_turn) == 0 } {
      set player_first [expr int(rand()*2)]
      set game_state(player_first)  [lindex $players $player_first]
      set game_state(player_second) [lindex $players [expr 1 - $player_first]]
      set game_state(player_turn) 1
    } elseif { ($game_state(player_first) == "") && ($game_state(player_second) == "") } {
      set game_state(player_first)  [lindex $players 0]
      set game_state(player_second) [lindex $players 1]
    } elseif { $game_state(player_first) == "" } {
      set game_state(player_first) $name
    } elseif { $game_state(player_second) == "" } {
      set game_state(player_second) $name
    }

    # Manage the turn
    ManageTurn 0
  } else {
    # All client must wait for the other players to join
    UpdateGameState
  }
}

# Client disconnexion
proc Disconnect {{sock ""} {name ""}} {
  variable game_state
  upvar 1 state state

  # Get socket to disconnect
  puts stderr "> Disconnecting..."
  if { $sock == "" } {
    set sock $state(socket)
  } else {
    puts $sock "BOARD_Exit"
  }
  if { $name == "" } {
    set name $state(name)
  }

  # Remove player
  set reset 0
  set player_list {}
  foreach player $game_state(player_list) {
    if { [lindex $player 2] != $sock } {
      lappend player_list $player
    } else {
      # Remove him from players (will be replaced by the next one to connect)
      if { $game_state(player_first) == [lindex $player 0] } {
        set game_state(player_first) ""
      }
      if { $game_state(player_second) == [lindex $player 0] } {
        set game_state(player_second) ""
      }
    }
  }
  set game_state(player_list) $player_list

  # Close socket
  slaveServer::closeSocket $sock

  # If nobody there, start a new game and do nothing
  if { [llength $player_list] == 0 } {
    NewGame
  } else {
    # Inform about deconnexion
    SendMessageToAll "CHAT_DisplayMessage {$name s'est deconnecte} {black}"
    # Update game state
    UpdateGameState
  }
}


