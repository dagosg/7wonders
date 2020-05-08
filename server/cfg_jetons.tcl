#!/usr/bin/tclsh
# bonus: Gold / PV

set JETONS {}
array set jeton ""
set jeton(name)  "architecture"
set jeton(image) "jeton_architecture.png"
set jeton(item)  0
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "2 ressources en moins pour construire les merveilles"
lappend JETONS [array get jeton]

set jeton(name)  "agriculture"
set jeton(image) "jeton_agriculture.png"
set jeton(item)  1
set jeton(bonus) {6 4}
set jeton(owner) ""
set jeton(desc)  "6 pièces d'or + 4 PV"
lappend JETONS [array get jeton]

set jeton(name)  "économie"
set jeton(image) "jeton_economie.png"
set jeton(item)  2
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "Récuperer l'or dépensé par l'adversaire lors du commerce"
lappend JETONS [array get jeton]

set jeton(name)  "LOI"
set jeton(image) "jeton_loi.png"
set jeton(item)  3
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "Gagner par la science avec 5 cartes vertes différentes au lieu de 6"
lappend JETONS [array get jeton]

set jeton(name)  "maçonnerie"
set jeton(image) "jeton_maconnerie.png"
set jeton(item)  4
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "2 ressources de moins pour construire les cartes bleus"
lappend JETONS [array get jeton]

set jeton(name)  "mathématiques"
set jeton(image) "jeton_mathematiques.png"
set jeton(item)  5
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "3 PV x nombre de jetons verts"
lappend JETONS [array get jeton]

set jeton(name)  "philosophie"
set jeton(image) "jeton_philosophie.png"
set jeton(item)  6
set jeton(bonus) {0 7}
set jeton(owner) ""
set jeton(desc)  "7 PV"
lappend JETONS [array get jeton]

set jeton(name)  "stratégie"
set jeton(image) "jeton_strategie.png"
set jeton(item)  7
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "+1 guerrier lors de la construction de cartes rouges"
lappend JETONS [array get jeton]

set jeton(name)  "théologie"
set jeton(image) "jeton_theologie.png"
set jeton(item)  8
set jeton(bonus) {0 0}
set jeton(owner) ""
set jeton(desc)  "Rejouer après la construction des merveilles"
lappend JETONS [array get jeton]

set jeton(name)  "urbanisme"
set jeton(image) "jeton_urbanisme.png"
set jeton(item)  9
set jeton(bonus) {6 0}
set jeton(owner) ""
set jeton(desc)  "6 pièces d'or + 4 pièces d'or pour chaque carte construite par chaînage"
lappend JETONS [array get jeton]

