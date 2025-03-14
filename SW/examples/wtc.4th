\ MECB suport words djrm Oct 2024
rtcload
18 string-table month-table-bcd
" Jan" " Feb" " Mar" " Apr" " May" " Jun" " Jul" " Aug" " Sep"
" 10" " 11" " 12" " 13" " 14" " 15" " Oct" " Nov" " Dec"
MONITOR
: wdate ( -- ) 
  CR WTC@ base @ >r hex 
  swap rot 2digitsout [CHAR] : EMIT
  2digitsout [CHAR] : EMIT 2digitsout [CHAR] : EMIT
  BL EMIT swap rot
  $20 2digitsout 2digitsout
  BL EMIT month-table-bcd
  2digitsout r> base ! ;
wdate  

