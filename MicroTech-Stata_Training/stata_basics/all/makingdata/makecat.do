recode rent ///
  (1300/max=4 "$1300 and above") ///
  (1000/1300=3 "$1000 to under $1300") ///
  (800/1000=2 "$800 to under $1000") ///
  (min/800=1 "under $800") ///
  , gen(rentgrp)
