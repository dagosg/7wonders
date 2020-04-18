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

set CARDS1 {}
array set card ""
set card(name)  "VERRERIE"
set card(image) "cards1_verrerie.png"
set card(price) {0 0 0 0 0 1}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 1}
set card(green) 0
set card(extra) 0
set card(color) "gray"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "DEPOT DE PIERRE"
set card(image) "cards1_depot_pierre.png"
set card(price) {0 0 0 0 0 3}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 1 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "ATELIER"
set card(image) "cards1_atelier.png"
set card(price) {0 0 0 1 0 0}
set card(chain) {0 0}
set card(bonus) {0 1 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 1
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "SCRIPTORIUM"
set card(image) "cards1_scriptorium.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {1 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 2
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "OFFICINE"
set card(image) "cards1_officine.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {2 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 4
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "APOTHICAIRE"
set card(image) "cards1_apothicaire.png"
set card(price) {0 0 0 0 1 0}
set card(chain) {0 0}
set card(bonus) {0 1 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 3
set card(extra) 0
set card(color) "green"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "AUTEL"
set card(image) "cards1_autel.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {3 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "BAINS"
set card(image) "cards1_bains.png"
set card(price) {0 0 1 0 0 0}
set card(chain) {4 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "BASSIN ARGILEUX"
set card(image) "cards1_bassin_argileux.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 1 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "CAVITE"
set card(image) "cards1_cavite.png"
set card(price) {0 0 0 0 0 1}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 1 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "CHANTIER"
set card(image) "cards1_chantier.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {1 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "DEPOT D'ARGILE"
set card(image) "cards1_depot_argile.png"
set card(price) {0 0 0 0 0 3}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 1 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "DEPOT DE BOIS"
set card(image) "cards1_depot_bois.png"
set card(price) {0 0 0 0 0 3}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {1 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "EXPLOITATION"
set card(image) "cards1_exploitation.png"
set card(price) {0 0 0 0 0 1}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {1 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "GISEMENT"
set card(image) "cards1_gisement.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 1 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "MINE"
set card(image) "cards1_mine.png"
set card(price) {0 0 0 0 0 1}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 1 0 0}
set card(green) 0
set card(extra) 0
set card(color) "brown"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "PRESSE"
set card(image) "cards1_presse.png"
set card(price) {0 0 0 0 0 1}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 1 0}
set card(green) 0
set card(extra) 0
set card(color) "gray"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "THEATRE"
set card(image) "cards1_theatre.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {5 0}
set card(bonus) {0 3 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "blue"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "TOUR DE GARDE"
set card(image) "cards1_tour_garde.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "PALISSADE"
set card(image) "cards1_palissade.png"
set card(price) {0 0 0 0 0 2}
set card(chain) {6 0}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "CASERNE"
set card(image) "cards1_caserne.png"
set card(price) {0 1 0 0 0 0}
set card(chain) {7 0}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "ECURIE"
set card(image) "cards1_ecurie.png"
set card(price) {1 0 0 0 0 0}
set card(chain) {8 0}
set card(bonus) {0 0 1}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "red"
set card(owner) ""
lappend CARDS1 [array get card]

set card(name)  "TAVERNE"
set card(image) "cards1_taverne.png"
set card(price) {0 0 0 0 0 0}
set card(chain) {9 0}
set card(bonus) {4 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 0
set card(color) "yellow"
set card(owner) ""
lappend CARDS1 [array get card]

