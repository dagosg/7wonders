#!/usr/bin/tclsh
# price: Wood / Clay / Stone / Parchment / Potion / Gold
# chain: {cards which chain this card)
# bonus: Gold / PV / Warriors
# depot (yellow): Wood / Clay / Stone / Parchment-Potion
# trade (yellow): Wood, clay and stone / Parchment and potion
# funds (brown/gray): Wood / Clay / Stone / Parchment / Potion
# green: [Symbol]
# extra: [Yallow & Purple cards bonus]
# color: Brown / Gray / Yellow / Blue / Green / Red / Purple

# Green symbols:
# 0: None
# 1: Atelier (1) - Laboratoire (2)
# 2: Scriptorium (1) - Bibliotheque (2)
# 3: Apothicaire (1) - Ecole (2)
# 4: Officine (1) - Dispensaire (2)
# 5: Universite (3) - Observatoire (3)
# 6: Etude (3) - Academie (3)

# Extra:
# 0: None
# 1: 2GoldxBrown
# 2: 3GoldxGray
# 3: 1GoldxYellow
# 4: 1GoldxRed
# 5: 2GoldxWonders

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

set CARDS3 {}
array set card ""

set card(name)  "UNIVERSITE"
set card(image) "cards3_universite.png"
set card(price) {0 1 0 1 1 0}
set card(chain) {0 12}
set card(bonus) {0 2 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 5
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "SENAT"
set card(image) "cards3_senat.png"
set card(price) {0 2 1 1 0 0}
set card(chain) {0 15}
set card(bonus) {0 5 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "PRETOIRE"
set card(image) "cards3_pretoire.png"
set card(price) {0 0 0 0 0 8}
set card(chain) {0 0}
set card(bonus) {0 0 3}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "PORT"
set card(image) "cards3_port.png"
set card(price) {1 0 0 1 1 0}
set card(chain) {0 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 1
set card(color) "yellow"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "PHARE"
set card(image) "cards3_phare.png"
set card(price) {0 2 0 0 1 0}
set card(chain) {0 9}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 3
set card(color) "yellow"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "PANTHEON"
set card(image) "cards3_pantheon.png"
set card(price) {1 1 0 2 0 0}
set card(chain) {0 17}
set card(bonus) {0 6 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "PALACE"
set card(image) "cards3_palace.png"
set card(price) {1 1 1 0 2 0}
set card(chain) {0 0}
set card(bonus) {0 7 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "OBSERVATOIRE"
set card(image) "cards3_observatoire.png"
set card(price) {0 0 1 2 0 0}
set card(chain) {0 13}
set card(bonus) {0 2 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 5
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "OBELISQUE"
set card(image) "cards3_obelisque.png"
set card(price) {0 0 2 0 1 0}
set card(chain) {0 0}
set card(bonus) {0 5 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "JARDINS"
set card(image) "cards3_jardins.png"
set card(price) {2 2 0 0 0 0}
set card(chain) {0 16}
set card(bonus) {0 6 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "HOTEL DE VILLE"
set card(image) "cards3_hotel_ville.png"
set card(price) {2 0 3 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 7 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "FORTIFICATIONS"
set card(image) "cards3_fortifications.png"
set card(price) {0 1 2 1 0 0}
set card(chain) {0 6}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ETUDE"
set card(image) "cards3_etude.png"
set card(price) {2 0 0 1 1 0}
set card(chain) {0 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 6
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ACADEMIE"
set card(image) "cards3_academie.png"
set card(price) {1 0 1 0 2 0}
set card(chain) {0 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 6
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "CIRQUE"
set card(image) "cards3_cirque.png"
set card(price) {0 2 2 0 0 0}
set card(chain) {0 14}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "CHAMBRE DE COMMERCE"
set card(image) "cards3_chambre_commerce.png"
set card(price) {0 0 0 2 0 0}
set card(chain) {0 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 2
set card(color) "yellow"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ARENE"
set card(image) "cards3_arene.png"
set card(price) {1 1 1 0 0 0}
set card(chain) {0 10}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 5
set card(color) "yellow"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ATELIER DE SIEGE"
set card(image) "cards3_atelier_siege.png"
set card(price) {3 0 0 0 1 0}
set card(chain) {0 11}
set card(bonus) {0 0 2}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ARSENAL"
set card(image) "cards3_arsenal.png"
set card(price) {2 3 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 3}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS3 [array get card]

set card(name)  "ARMURERIE"
set card(image) "cards3_armurerie.png"
set card(price) {0 0 2 0 1 0}
set card(chain) {0 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 4
set card(color) "yellow"
set card(owner) ""
lappend CARDS3 [array get card]


