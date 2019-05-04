

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
join_paths                = ( P... ) -> PATH.resolve PATH.join P...
abspath                   = ( P... ) -> join_paths __dirname, P...
{ to_width, width_of, }   = require 'to-width'
PSPG                      = require '../..'
path_1                    = abspath '../../src/experiments/test-data-1.tsv'
jr                        = JSON.stringify


#-----------------------------------------------------------------------------------------------------------
@demo_tabular_output = ->
  source    = PS.read_from_file path_1
  pipeline  = []
  pipeline.push source
  pipeline.push PS.$split_tsv()
  pipeline.push PS.$name_fields 'fncr', 'glyph', 'formula'
  pipeline.push @$add_random_words 10
  pipeline.push @$add_ncrs()
  pipeline.push @$add_numbers()
  pipeline.push @$reorder_fields()
  pipeline.push PSPG.$tee_as_table()
  pipeline.push PS.$drain()
  PS.pull pipeline...

#-----------------------------------------------------------------------------------------------------------
@demo_paged_output = ->
  source    = PS.read_from_file path_1
  pipeline  = []
  pipeline.push source
  pipeline.push PS.$split_tsv()
  pipeline.push PS.$name_fields 'fncr', 'glyph', 'formula'
  pipeline.push @$add_random_words 10
  pipeline.push @$add_ncrs()
  pipeline.push @$add_numbers()
  pipeline.push @$reorder_fields()
  pipeline.push @$as_line()
  pipeline.push PSPG.$page_output()
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

#-----------------------------------------------------------------------------------------------------------
@$as_line = -> $ ( d, send ) =>
    d  = jr d unless isa.text d
    d += '\n' unless isa.line d
    send d


############################################################################################################
unless module.parent?
  do =>
    @demo_tabular_output()
    # @demo_paged_output()


