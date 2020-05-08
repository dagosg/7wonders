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
# 5: Universite (3) - Observatoire (3)
# 6: Etude (3) - Academie (3)

# Extra:
# 0: None
# 1: 2Gold x Brown
# 2: 3Gold x Gray
# 3: 1Gold x Yellow
# 4: 1Gold x Red
# 5: 2Gold x Wonders
# 11: 1GoldPV x (Brown + Gray)
# 12: 1GoldPV x Yellow
# 13: 1GoldPV x Blue
# 14: 1GoldPV x Green
# 15: 1GoldPV x Red
# 16: 2PV x Wonders
# 17: 1PV x 3Gold

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
set card(name)  "verrerie"
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

set card(name)  "dépot de pierre"
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

set card(name)  "atelier"
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

set card(name)  "scriptorium"
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

set card(name)  "officine"
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

set card(name)  "apothicaire"
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

set card(name)  "autel"
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

set card(name)  "bains"
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

set card(name)  "bassin argileux"
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

set card(name)  "cavité"
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

set card(name)  "chantier"
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

set card(name)  "dépôt d'argile"
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

set card(name)  "dépôt de bois"
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

set card(name)  "exploitation"
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

set card(name)  "gisement"
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

set card(name)  "mine"
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

set card(name)  "presse"
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

set card(name)  "théâtre"
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

set card(name)  "tour de garde"
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

set card(name)  "palissade"
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

set card(name)  "caserne"
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

set card(name)  "écurie"
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

set card(name)  "taverne"
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

