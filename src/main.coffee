

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
types                     = require './types'
{ isa
  validate
  declare
  size_of
  type_of }               = types
#...........................................................................................................
require                   './exception-handler'
join_paths                = ( P... ) -> PATH.resolve PATH.join P...
abspath                   = ( P... ) -> join_paths __dirname, P...
{ to_width, width_of, }   = require 'to-width'
pull_stream_to_stream     = require 'pull-stream-to-stream'
new_pager                 = require 'default-pager'
path_to_pspg              = abspath '../pspg'

#-----------------------------------------------------------------------------------------------------------
@walk_table_rows = ( rows, keys, widths ) ->
  yield ' ' + (  ( ( to_width key, widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  yield '-' + (  ( ( to_width '', widths[ key ], { padder: '-', } ) for key in keys ).join '-+-' ) + '-'
  for row in rows
    yield ' ' + (  ( ( to_width ( row[ key ] ? '' ), widths[ key ] ) for key in keys ).join ' | ' ) + ' '
  yield "(#{rows.length} rows)"
  yield '\n\n'
  return null

#-----------------------------------------------------------------------------------------------------------
@$collect_etc = ->
  last      = Symbol 'last'
  rows      = []
  widths    = {}
  keys      = new Set()
  #.........................................................................................................
  return PS.$ { last, }, ( row, send ) =>
    if row is last
      # console.table rows
      send line for line from @walk_table_rows rows, [ keys..., ], widths
    else
      d = {}
      for key of row
        keys.add key
        d[ key ]      = value = row[ key ]?.toString() ? ''
        width         = width_of value
        widths[ key ] = Math.max 2, ( widths[ key ] ? 2 ), width
      rows.push d
    return null

#-----------------------------------------------------------------------------------------------------------
@$tee_as_table = ( settings, handler ) ->
  #.........................................................................................................
  pipeline = []
  pipeline.push @$collect_etc()
  pipeline.push @$page_output arguments...
  pipeline.push PS.$drain()
  #.........................................................................................................
  return PS.$tee PS.pull pipeline...

#-----------------------------------------------------------------------------------------------------------
@$page_output = ( settings, handler ) ->
  switch arity = arguments.length
    when 0 then null
    when 1
      if isa.function settings
        [ settings, handler, ] = [ null, settings, ]
    when 2 then null
    else throw new Error "µ33981 expected between 0 and 2 arguments, got #{arity}"
  validate.function handler   if handler?
  validate.object   settings  if settings?
  #.........................................................................................................
  defaults    =
    pager:  path_to_pspg
    args:   [  '-s17', '--force-uniborder', ]
  #.........................................................................................................
  settings    = if settings? then assign {}, defaults, settings else defaults
  source      = PS.new_push_source()
  stream      = pull_stream_to_stream.source PS.pull source
  stream.pipe new_pager settings, handler
  last        = Symbol 'last'
  #.........................................................................................................
  return PS.$watch { last, }, ( line ) ->
    return source.end() if line is last
    line  = '' unless line?
    line  = line.toString() unless isa.text line
    line += '\n'            unless isa.line line
    source.send line
    return null

