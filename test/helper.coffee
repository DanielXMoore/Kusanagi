global.assert = require "assert"

parser = require "../source/kusanagi"
generate = require "../source/generate"

compare = (src, result) ->
  assert.equal generate(parser.parse(src, verbose: false)), result

throws = (src) ->
  assert.throws ->
    generate(parser.parse(src))

module.exports =
  compare: compare
  throws: throws
