parser = require "../source/grammar"

{readFileSync} = require "fs"

describe.skip "Motoko Grammar", ->
  it "should parse .mo files", ->
    assert parser.parse readFileSync("./test/examples/Alarm.mo", "utf8")
