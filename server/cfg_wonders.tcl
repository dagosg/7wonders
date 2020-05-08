#!/usr/bin/tclsh
# price: Wood / Clay / Stone / Parchment / Potion
# bwar:  Brown cards / Gray cards / Warriors
# bonus: Win gold / Lose enemy gold / PV / Replay
# trade: Wood, clay and stone / Parchment and potion
# trick: Jetons / Defausse

set WONDERS {}
array set wonder ""
set wonder(name)  "la via appia"
set wonder(image) "wonder_appia.png"
set wonder(price) {0 2 2 1 0}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {3 3 3 1}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le circus maximus"
set wonder(image) "wonder_circus.png"
set wonder(price) {1 0 2 0 1}
set wonder(bwar)  {0 1 1}
set wonder(bonus) {0 0 3 0}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le colosse"
set wonder(image) "wonder_colosse.png"
set wonder(price) {0 3 0 0 1}
set wonder(bwar)  {0 0 2}
set wonder(bonus) {0 0 3 0}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "les jardins suspendus"
set wonder(image) "wonder_garden.png"
set wonder(price) {2 0 0 1 1}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {6 0 3 1}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "la grande bibliothèque"
set wonder(image) "wonder_library.png"
set wonder(price) {3 0 0 1 1}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 4 0}
set wonder(trade) {0 0}
set wonder(trick) {3 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le mausolée"
set wonder(image) "wonder_mausolee.png"
set wonder(price) {0 2 0 1 2}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 2 0}
set wonder(trade) {0 0}
set wonder(trick) {0 1}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le grand phare"
set wonder(image) "wonder_phare.png"
set wonder(price) {1 0 1 2 0}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 4 0}
set wonder(trade) {1 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le pirée"
set wonder(image) "wonder_piree.png"
set wonder(price) {2 1 1}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 2 1}
set wonder(trade) {0 1}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "les pyramides"
set wonder(image) "wonder_pyramides.png"
set wonder(price) {0 0 3 1 0}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 9 0}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le sphinx"
set wonder(image) "wonder_sphinx.png"
set wonder(price) {0 1 1 0 2}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {0 0 6 1}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "le temple d'Artémis"
set wonder(image) "wonder_temple.png"
set wonder(price) {1 0 1 1 1}
set wonder(bwar)  {0 0 0}
set wonder(bonus) {12 0 0 1}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]

set wonder(name)  "la statue de Zeus"
set wonder(image) "wonder_zeus.png"
set wonder(price) {1 1 1 2 0}
set wonder(bwar)  {1 0 1}
set wonder(bonus) {0 0 3 0}
set wonder(trade) {0 0}
set wonder(trick) {0 0}
set wonder(owner) ""
set wonder(built) 0
lappend WONDERS [array get wonder]


