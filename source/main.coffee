{ parse } = require "./kusanagi"
generate = require "./generate"

defaultOptions = {}

module.exports =
  parse: parse
  compile: (src, options=defaultOptions) ->
    filename = options.filename or "unknown"
    ast = parse src,
      filename: filename

    if options.ast
      return ast

    generate ast, options
  generate: generate
