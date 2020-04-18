#!/usr/bin/tclsh
# price: Wood / Clay / Stone / Parchment / Potion / Gold
# chain: {cards which chain this card)
# bonus: Gold / PV / Warriors
# depot (yellow): Wood / Clay / Stone / Parchment-Potion
# trade (yellow): Wood, clay and stone / Parchment and potion
# funds (brown/gray): Wood / Clay / Stone / Parchment / Potion
# green: [Symbol]
# extra: [Purple cards bonus]
# color: Brown / Gray / Yellow / Blue / Green / Red / Purple

# Green symbols:
# 0: None
# 1: Atelier (1) - Laboratoire (2)
# 2: Scriptorium (1) - Bibliotheque (2)
# 3: Apothicaire (1) - Ecole (2)
# 4: Officine (1) - Dispensaire (2)

# Chains
# 0: None
# 1: Bouquin
# 2: Roue
# 3: Lune
# 4: Goutte
# 5: Masque
# 6: Mur
# 7: Epe
# 8: Sabot
# 9: Jarre
# 10: Baril
# 11: Cible
# 12: Lyre
# 13: Theiere
# 14: Casque
# 15: Parlement
# 16: Colonne
# 17: Soleil

set CARDS2 {}
array set card ""
set card(name)  "AQUEDUC"
set card(image) "cards2_aqueduc.png"
set card(price) {0 0 3 0 0 0}
set card(chain) {0 4}
set card(bonus) {0 5 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "CARRIERE"
set card(image) "cards2_carriere.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 2 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "BARAQUEMENTS"
set card(image) "cards2_baraquements.png"
set card(price) {0 0 0 0 0 3}
set card(chain) {0 7}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "BIBLIOTHEQUE"
set card(image) "cards2_bibliotheque.png"
set card(price) {1 0 1 0 1 0}
set card(chain) {0 1}
set card(bonus) {0 2 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 2
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "BRASSERIE"
set card(image) "cards2_brasserie.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {10 0}
set card(bonus) {6 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "BRIQUETERIE"
set card(image) "cards2_briqueterie.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 2 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "CARAVANSERAIL"
set card(image) "cards2_caravanserail.png"
set card(price) {0 0 0 1 1 2}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {1 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "CHAMPS DE TIR"
set card(image) "cards2_champs_tir.png"
set card(price) {1 0 1 1 0 0}
set card(chain) {11 0}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "DOUANE"
set card(image) "cards2_douane.png"
set card(price) {0 0 0 0 0 4}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 1}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "DISPENSAIRE"
set card(image) "cards2_dispensaire.png"
set card(price) {0 2 1 0 0 0}
set card(chain) {0 2}
set card(bonus) {0 2 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 4
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "ECOLE"
set card(image) "cards2_ecole.png"
set card(price) {1 0 0 2 0 0}
set card(chain) {12 0}
set card(bonus) {0 1 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 3
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "FORUM"
set card(image) "cards2_forum.png"
set card(price) {0 1 0 0 0 3}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 1}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "HARAS"
set card(image) "cards2_haras.png"
set card(price) {1 1 0 0 0 0}
set card(chain) {0 8}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "LABORATOIRE"
set card(image) "cards2_laboratoire.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {13 0}
set card(bonus) {0 1 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 1
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "MURAILLE"
set card(image) "cards2_muraille.png"
set card(price) {0 0 2 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "PLACE D'ARMES"
set card(image) "cards2_place_armes.png"
set card(price) {0 2 0 0 1 0}
set card(chain) {14 0}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "ROSTRES"
set card(image) "cards2_rostres.png"
set card(price) {1 0 1 0 0 0}
set card(chain) {15 0}
set card(bonus) {0 4 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "SCIERIE"
set card(image) "cards2_scierie.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {2 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "SECHOIR"
set card(image) "cards2_sechoir.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 1 0}
set card(green) 0
set card(extra) 0
set card(color) "gray"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "SOUFFLERIE"
set card(image) "cards2_soufflerie.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 1}
set card(green) 0
set card(extra) 0
set card(color) "gray"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "STATUE"
set card(image) "cards2_statue.png"
set card(price) {0 2 0 0 0 0}
set card(chain) {16 5}
set card(bonus) {0 4 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "TEMPLE"
set card(image) "cards2_temple.png"
set card(price) {1 0 0 1 0 0}
set card(chain) {17 3}
set card(bonus) {0 4 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS2 [array get card]

set card(name)  "TRIBUNAL"
set card(image) "cards2_tribunal.png"
set card(price) {2 0 0 0 1 0}
set card(chain) {0 0}
set card(bonus) {0 5 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS2 [array get card]


