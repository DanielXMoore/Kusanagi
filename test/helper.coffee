global.assert = require "assert"

parser = require "../source/kusanagi"
generate = require "../source/generate"

compile = (src, opts) ->
  generate(parser.parse(src, opts))

throws = (src) ->
  assert.throws ->
    generate(parser.parse(src))

compare = (src, result, filename) ->
  compileResult = compile src, {
    filename
    verbose: false
  }

  assert.equal compileResult, result, """
    #{filename}
    --- Source   ---
    #{src}

    --- Expected ---
    #{result}

    --- Got      ---
    #{compileResult}

  """

testCase = (text, opt) ->
  [desc, src, result] = text.split("\n---\n")

  if opt
    fn = it[opt]
  else
    fn = it

  fn desc, ->
    compare src, result, desc

testCase.only = (text) ->
  testCase(text, "only")

testCase.skip = (text) ->
  testCase(text, "skip")

module.exports = {
  compare
  testCase
  throws
}
