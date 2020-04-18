#!/usr/bin/tclsh
# bonus: Gold / PV

set JETONS {}
array set jeton ""
set jeton(name)  "ARCHITECTURE"
set jeton(image) "jeton_architecture.png"
set jeton(item)  0
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "AGRICULTURE"
set jeton(image) "jeton_agriculture.png"
set jeton(item)  1
set jeton(bonus) {6 4}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "ECONOMIE"
set jeton(image) "jeton_economie.png"
set jeton(item)  2
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "LOI"
set jeton(image) "jeton_loi.png"
set jeton(item)  3
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "MACONNERIE"
set jeton(image) "jeton_maconnerie.png"
set jeton(item)  4
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "MATHEMATIQUES"
set jeton(image) "jeton_mathematiques.png"
set jeton(item)  5
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "PHILOSOPHIE"
set jeton(image) "jeton_philosophie.png"
set jeton(item)  6
set jeton(bonus) {0 7}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "STRATEGIE"
set jeton(image) "jeton_strategie.png"
set jeton(item)  7
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "THEOLOGIE"
set jeton(image) "jeton_theologie.png"
set jeton(item)  8
set jeton(bonus) {0 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

set jeton(name)  "URBANISME"
set jeton(image) "jeton_urbanisme.png"
set jeton(item)  9
set jeton(bonus) {6 0}
set jeton(owner) ""
lappend JETONS [array get jeton]

