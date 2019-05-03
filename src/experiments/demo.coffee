

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'PSPG/EXPERIMENTS/DEMO'
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
help                      = CND.get_logger 'help',      badge
whisper                   = CND.get_logger 'whisper',   badge
echo                      = CND.echo.bind CND
#...........................................................................................................
# FS                        = require 'fs'
PATH                      = require 'path'
PS                        = require 'pipestreams'
{ $
  $async
  select }                = PS
# types                     = require '../types'
# { isa
#   validate
#   declare
#   size_of
#   type_of }               = types
# #...........................................................................................................
# require                   '../exception-handler'
#...........................................................................................................
join_paths                = ( P... ) -> PATH.resolve PATH.join P...
abspath                   = ( P... ) -> join_paths __dirname, P...
{ to_width, width_of, }   = require 'to-width'

#-----------------------------------------------------------------------------------------------------------
@print_table = ( rows, keys, widths ) =>
  ### headings ###
  echo ' ' + (  ( ( to_width key, widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  ### divider ###
  echo '-' + (  ( ( to_width '', widths[ key ], { padder: '-', } ) for key in keys ).join '-+-' ) + '-'
  ### data ###
  for row in rows
    echo ' ' + (  ( ( to_width row[ key ], widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  echo "(#{rows.length} rows)"
  echo '\n\n'
  return null

#-----------------------------------------------------------------------------------------------------------
@$tee_as_table = =>
  last                    = Symbol 'last'
  collector               = []
  widths                  = {}
  keys                    = null
  #.........................................................................................................
  collect_etc = PS.$watch { last, }, ( row ) =>
    if row is last
      # console.table collector
      @print_table collector, keys, widths
    else
      keys ?= ( key for key of row )
      collector.push row
      for key of row
        width         = width_of row[ key ]
        widths[ key ] = Math.max ( widths[ key ] ? 0 ), width
    return null
  #.........................................................................................................
  pipeline = []
  pipeline.push collect_etc
  pipeline.push PS.$drain()
  #.........................................................................................................
  return PS.$tee PS.pull pipeline...


do ->
  ###
  https://github.com/dominictarr/default-pager
  https://stackoverflow.com/a/53190286/7568091
  https://github.com/jprichardson/node-kexec
  ###
  pull_stream_to_stream     = require 'pull-stream-to-stream'
  new_pager                 = require 'default-pager'

  pager_settings  =
    pager:  abspath '../../pspg'
    args:   [  '-s17', '--force-uniborder', ]

  # stream    = FS.createReadStream PATH.join __dirname, '../../README.md'

  pipeline  = []
  source    = PS.new_push_source()
  pipeline.push source
  stream    = pull_stream_to_stream.source PS.pull pipeline...
  stream.pipe new_pager pager_settings, -> urge 'ok'

  output = ( t ) -> source.send t + '\n'
  end_output = -> source.end()


  output """  a  | ?column? | ?column? | ?column? | ?column? |                                      ?column?                                       | ?column?  |  ?column?   """
  output """-----+----------+----------+----------+----------+-------------------------------------------------------------------------------------+-----------+-------------"""
  output """   1 |        1 |        1 |        1 |        1 | fobbarbaz                                                                           |         1 |           1 """
  output """   2 |        1 |        2 |        4 |        8 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |        16 |          32 """
  output """   3 |        1 |        3 |        9 |       27 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |        81 |         243 """
  output """   4 |        1 |        4 |       16 |       64 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |       256 |        1024 """
  output """   5 |        1 |        5 |       25 |      125 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |       625 |        3125 """
  output """   6 |        1 |        6 |       36 |      216 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |      1296 |        7776 """
  output """   7 |        1 |        7 |       49 |      343 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |      2401 |       16807 """
  output """   8 |        1 |        8 |       64 |      512 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |      4096 |       32768 """
  output """   9 |        1 |        9 |       81 |      729 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |      6561 |       59049 """
  output """  10 |        1 |       10 |      100 |     1000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     10000 |      100000 """
  output """  11 |        1 |       11 |      121 |     1331 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     14641 |      161051 """
  output """  12 |        1 |       12 |      144 |     1728 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     20736 |      248832 """
  output """  13 |        1 |       13 |      169 |     2197 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     28561 |      371293 """
  output """  14 |        1 |       14 |      196 |     2744 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     38416 |      537824 """
  output """  15 |        1 |       15 |      225 |     3375 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     50625 |      759375 """
  output """  16 |        1 |       16 |      256 |     4096 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     65536 |     1048576 """
  output """  17 |        1 |       17 |      289 |     4913 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |     83521 |     1419857 """
  output """  18 |        1 |       18 |      324 |     5832 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    104976 |     1889568 """
  output """  19 |        1 |       19 |      361 |     6859 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    130321 |     2476099 """
  output """  20 |        1 |       20 |      400 |     8000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    160000 |     3200000 """
  output """  21 |        1 |       21 |      441 |     9261 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    194481 |     4084101 """
  output """  22 |        1 |       22 |      484 |    10648 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    234256 |     5153632 """
  output """  23 |        1 |       23 |      529 |    12167 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    279841 |     6436343 """
  output """  24 |        1 |       24 |      576 |    13824 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    331776 |     7962624 """
  output """  25 |        1 |       25 |      625 |    15625 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    390625 |     9765625 """
  output """  26 |        1 |       26 |      676 |    17576 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    456976 |    11881376 """
  output """  27 |        1 |       27 |      729 |    19683 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    531441 |    14348907 """
  output """  28 |        1 |       28 |      784 |    21952 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    614656 |    17210368 """
  output """  29 |        1 |       29 |      841 |    24389 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    707281 |    20511149 """
  output """  30 |        1 |       30 |      900 |    27000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    810000 |    24300000 """
  output """  31 |        1 |       31 |      961 |    29791 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |    923521 |    28629151 """
  output """  32 |        1 |       32 |     1024 |    32768 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1048576 |    33554432 """
  output """  33 |        1 |       33 |     1089 |    35937 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1185921 |    39135393 """
  output """  34 |        1 |       34 |     1156 |    39304 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1336336 |    45435424 """
  output """  35 |        1 |       35 |     1225 |    42875 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1500625 |    52521875 """
  output """  36 |        1 |       36 |     1296 |    46656 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1679616 |    60466176 """
  output """  37 |        1 |       37 |     1369 |    50653 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   1874161 |    69343957 """
  output """  38 |        1 |       38 |     1444 |    54872 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   2085136 |    79235168 """
  output """  39 |        1 |       39 |     1521 |    59319 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   2313441 |    90224199 """
  output """  40 |        1 |       40 |     1600 |    64000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   2560000 |   102400000 """
  output """  41 |        1 |       41 |     1681 |    68921 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   2825761 |   115856201 """
  output """  42 |        1 |       42 |     1764 |    74088 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   3111696 |   130691232 """
  output """  43 |        1 |       43 |     1849 |    79507 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   3418801 |   147008443 """
  output """  44 |        1 |       44 |     1936 |    85184 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   3748096 |   164916224 """
  output """  45 |        1 |       45 |     2025 |    91125 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   4100625 |   184528125 """
  output """  46 |        1 |       46 |     2116 |    97336 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   4477456 |   205962976 """
  output """  47 |        1 |       47 |     2209 |   103823 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   4879681 |   229345007 """
  output """  48 |        1 |       48 |     2304 |   110592 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   5308416 |   254803968 """
  output """  49 |        1 |       49 |     2401 |   117649 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   5764801 |   282475249 """
  output """  50 |        1 |       50 |     2500 |   125000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   6250000 |   312500000 """
  output """  51 |        1 |       51 |     2601 |   132651 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   6765201 |   345025251 """
  output """  52 |        1 |       52 |     2704 |   140608 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   7311616 |   380204032 """
  output """  53 |        1 |       53 |     2809 |   148877 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   7890481 |   418195493 """
  output """  54 |        1 |       54 |     2916 |   157464 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   8503056 |   459165024 """
  output """  55 |        1 |       55 |     3025 |   166375 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   9150625 |   503284375 """
  output """  56 |        1 |       56 |     3136 |   175616 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |   9834496 |   550731776 """
  output """  57 |        1 |       57 |     3249 |   185193 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  10556001 |   601692057 """
  output """  58 |        1 |       58 |     3364 |   195112 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  11316496 |   656356768 """
  output """  59 |        1 |       59 |     3481 |   205379 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  12117361 |   714924299 """
  output """  60 |        1 |       60 |     3600 |   216000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  12960000 |   777600000 """
  output """  61 |        1 |       61 |     3721 |   226981 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  13845841 |   844596301 """
  output """  62 |        1 |       62 |     3844 |   238328 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  14776336 |   916132832 """
  output """  63 |        1 |       63 |     3969 |   250047 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  15752961 |   992436543 """
  output """  64 |        1 |       64 |     4096 |   262144 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  16777216 |  1073741824 """
  output """  65 |        1 |       65 |     4225 |   274625 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  17850625 |  1160290625 """
  output """  66 |        1 |       66 |     4356 |   287496 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  18974736 |  1252332576 """
  output """  67 |        1 |       67 |     4489 |   300763 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  20151121 |  1350125107 """
  output """  68 |        1 |       68 |     4624 |   314432 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  21381376 |  1453933568 """
  output """  69 |        1 |       69 |     4761 |   328509 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  22667121 |  1564031349 """
  output """  70 |        1 |       70 |     4900 |   343000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  24010000 |  1680700000 """
  output """  71 |        1 |       71 |     5041 |   357911 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  25411681 |  1804229351 """
  output """  72 |        1 |       72 |     5184 |   373248 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  26873856 |  1934917632 """
  output """  73 |        1 |       73 |     5329 |   389017 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  28398241 |  2073071593 """
  output """  74 |        1 |       74 |     5476 |   405224 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  29986576 |  2219006624 """
  output """  75 |        1 |       75 |     5625 |   421875 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  31640625 |  2373046875 """
  output """  76 |        1 |       76 |     5776 |   438976 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  33362176 |  2535525376 """
  output """  77 |        1 |       77 |     5929 |   456533 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  35153041 |  2706784157 """
  output """  78 |        1 |       78 |     6084 |   474552 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  37015056 |  2887174368 """
  output """  79 |        1 |       79 |     6241 |   493039 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  38950081 |  3077056399 """
  output """  80 |        1 |       80 |     6400 |   512000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  40960000 |  3276800000 """
  output """  81 |        1 |       81 |     6561 |   531441 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  43046721 |  3486784401 """
  output """  82 |        1 |       82 |     6724 |   551368 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  45212176 |  3707398432 """
  output """  83 |        1 |       83 |     6889 |   571787 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  47458321 |  3939040643 """
  output """  84 |        1 |       84 |     7056 |   592704 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  49787136 |  4182119424 """
  output """  85 |        1 |       85 |     7225 |   614125 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  52200625 |  4437053125 """
  output """  86 |        1 |       86 |     7396 |   636056 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  54700816 |  4704270176 """
  output """  87 |        1 |       87 |     7569 |   658503 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  57289761 |  4984209207 """
  output """  88 |        1 |       88 |     7744 |   681472 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  59969536 |  5277319168 """
  output """  89 |        1 |       89 |     7921 |   704969 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  62742241 |  5584059449 """
  output """  90 |        1 |       90 |     8100 |   729000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  65610000 |  5904900000 """
  output """  91 |        1 |       91 |     8281 |   753571 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  68574961 |  6240321451 """
  output """  92 |        1 |       92 |     8464 |   778688 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  71639296 |  6590815232 """
  output """  93 |        1 |       93 |     8649 |   804357 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  74805201 |  6956883693 """
  output """  94 |        1 |       94 |     8836 |   830584 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  78074896 |  7339040224 """
  output """  95 |        1 |       95 |     9025 |   857375 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  81450625 |  7737809375 """
  output """  96 |        1 |       96 |     9216 |   884736 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  84934656 |  8153726976 """
  output """  97 |        1 |       97 |     9409 |   912673 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  88529281 |  8587340257 """
  output """  98 |        1 |       98 |     9604 |   941192 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  92236816 |  9039207968 """
  output """  99 |        1 |       99 |     9801 |   970299 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx |  96059601 |  9509900499 """
  output """ 100 |        1 |      100 |    10000 |  1000000 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | 100000000 | 10000000000 """
  output """(100 rows)"""
  end_output()
