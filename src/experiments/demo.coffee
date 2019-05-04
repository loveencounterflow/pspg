

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
types                     = require '../types'
{ isa
  validate
  declare
  size_of
  type_of }               = types
#...........................................................................................................
require                   '../exception-handler'
#...........................................................................................................
join_paths                = ( P... ) -> PATH.resolve PATH.join P...
abspath                   = ( P... ) -> join_paths __dirname, P...
{ to_width, width_of, }   = require 'to-width'
pull_stream_to_stream     = require 'pull-stream-to-stream'
new_pager                 = require 'default-pager'
path_to_pspg              = abspath '../../pspg'

'/usr/share/dict/words'
path_1 = abspath '../../src/experiments/test-data-1.tsv'


#-----------------------------------------------------------------------------------------------------------
@walk_table_rows = ( rows, keys, widths ) ->
  yield ' ' + (  ( ( to_width key, widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  yield '-' + (  ( ( to_width '', widths[ key ], { padder: '-', } ) for key in keys ).join '-+-' ) + '-'
  for row in rows
    yield ' ' + (  ( ( to_width row[ key ], widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  yield "(#{rows.length} rows)"
  yield '\n\n'
  return null


#-----------------------------------------------------------------------------------------------------------
@$collect_etc = ->
  last      = Symbol 'last'
  collector = []
  widths    = {}
  keys      = null
  #.........................................................................................................
  return PS.$ { last, }, ( row, send ) =>
    if row is last
      # console.table collector
      send line for line from @walk_table_rows collector, keys, widths
    else
      keys ?= ( key for key of row )
      d     = {}
      for key of row
        d[ key ]      = value = row[ key ].toString()
        width         = width_of value
        widths[ key ] = Math.max ( widths[ key ] ? 0 ), width
      collector.push d
    return null

#-----------------------------------------------------------------------------------------------------------
@$tee_as_table = =>
  #.........................................................................................................
  pipeline = []
  pipeline.push @$collect_etc()
  pipeline.push @$page_output()
  pipeline.push PS.$drain()
  #.........................................................................................................
  return PS.$tee PS.pull pipeline...

#-----------------------------------------------------------------------------------------------------------
@$page_output = ( settings = null ) ->
  defaults    =
    pager:  path_to_pspg
    args:   [  '-s17', '--force-uniborder', ]
  #.........................................................................................................
  settings    = if settings? then assign {}, defaults, settings else defaults
  source      = PS.new_push_source()
  stream      = pull_stream_to_stream.source PS.pull source
  stream.pipe new_pager settings, -> urge 'ok'
  last        = Symbol 'last'
  #.........................................................................................................
  return PS.$watch { last, }, ( line ) ->
    return source.end() if line is last
    line  = line.toString() unless isa.text line
    line += '\n'            unless isa.line line
    source.send line
    return null

#-----------------------------------------------------------------------------------------------------------
@demo = ->
  source    = PS.read_from_file path_1
  pipeline  = []
  pipeline.push source
  pipeline.push PS.$split_tsv()
  pipeline.push PS.$name_fields 'fncr', 'glyph', 'formula'
  pipeline.push @$add_random_words 10
  pipeline.push @$add_ncrs()
  pipeline.push @$add_numbers()
  pipeline.push @$reorder_fields()
  pipeline.push @$tee_as_table()
  # pipeline.push @$page_output()
  pipeline.push PS.$show()
  pipeline.push PS.$drain()
  PS.pull pipeline...

#-----------------------------------------------------------------------------------------------------------
@$reorder_fields = -> $ ( row, send ) =>
  { nr
    fncr
    nr2
    glyph
    glyph_ncr
    nr3
    formula
    formula_ncr
    bs }        = row
  send { nr, fncr, nr2, glyph, glyph_ncr, nr3, formula, formula_ncr, bs, }

#-----------------------------------------------------------------------------------------------------------
@$add_ncrs = ->
  return $ ( row, send ) =>
    row.glyph_ncr   = to_width ( @text_as_ncrs row.glyph    ), 20
    row.formula_ncr = to_width ( @text_as_ncrs row.formula  ), 20
    send row

#-----------------------------------------------------------------------------------------------------------
@$add_numbers = ->
  nr = 0
  return $ ( row, send ) =>
    nr             += +1
    row.nr          = nr
    row.nr2         = nr ** 2
    row.nr3         = nr ** 3
    send row

#-----------------------------------------------------------------------------------------------------------
@text_as_ncrs = ( text ) ->
  R = []
  for chr in Array.from text
    cid_hex = ( chr.codePointAt 0 ).toString 16
    R.push "&#x#{cid_hex};"
  return R.join ''

#-----------------------------------------------------------------------------------------------------------
@$add_random_words = ( n = 1 ) ->
  validate.count n
  CP    = require 'child_process'
  count = Math.min 1e5, n * 1000
  words = ( ( CP.execSync "shuf -n #{count} /usr/share/dict/words" ).toString 'utf-8' ).split '\n'
  words = ( word.replace /'s$/g, '' for word in words )
  words = ( word for word in words when word isnt '' )
  return $ ( fields, send ) =>
    fields.bs = ( words[ CND.random_integer 0, count ] for _ in [ 0 .. n ] ).join ' '
    send fields


############################################################################################################
unless module.parent?
  do =>
    @demo()


