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

set CARDS4 {}
array set card ""

set card(name)  "guilde des armateurs"
set card(image) "cards4_guilde_armateurs.png"
set card(price) {0 1 1 1 1 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 11
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des commerçants"
set card(image) "cards4_guilde_commercants.png"
set card(price) {1 1 0 1 1 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 12
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des magistrats"
set card(image) "cards4_guilde_magistrats.png"
set card(price) {2 1 0 1 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 13
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des scientifiques"
set card(image) "cards4_guilde_scientifiques.png"
set card(price) {2 2 0 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 14
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des tacticiens"
set card(image) "cards4_guilde_tacticiens.png"
set card(price) {0 1 2 1 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 15
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des bâtisseurs"
set card(image) "cards4_guilde_batisseurs.png"
set card(price) {1 1 2 0 1 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 16
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

set card(name)  "guilde des usuriers"
set card(image) "cards4_guilde_usuriers.png"
set card(price) {2 0 2 0 0 0}
set card(chain) {0 0}
set card(bonus) {0 0 0}
set card(depot) {0 0 0 0}
set card(trade) {0 0}
set card(funds) {0 0 0 0 0}
set card(green) 0
set card(extra) 17
set card(color) "purple"
set card(owner) ""
lappend CARDS4 [array get card]

