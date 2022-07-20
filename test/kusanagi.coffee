parser = require "../source/kusanagi"

{readFileSync} = require "fs"

generate = require "../source/generate"

describe "Kusanagi", ->
  describe "Parsing Examples", ->
    [
      "Basic"
      "Full"
      # TODO: "NestedObject"
      "NestedVariant"
      "Type"
    ].forEach (file) ->
      it file, ->
        assert parser.parse readFileSync("./test/examples/#{file}.ku", "utf8")

  describe "Parsing .mo files", ->
    [
      "Alarm.mo"
      "heros.mo"
      "JSON.mo"
      "Loop.mo"
      "Property.mo"
      "Pub.mo"
      "Sub.mo"
      "Switch.mo"
      "TryCatch.mo"
      "life/Grid.mo"
      "life/Random.mo"
      "life/State.mo"
      "life/main.mo"
      "uuid/Source.mo"
    ].forEach (file) ->

      it file, ->
        assert parser.parse readFileSync("./test/examples/#{file}", "utf8")

  it "nested variant", ->
    assert.equal generate(parser.parse readFileSync("./test/examples/NestedVariant.ku", "utf8")), """
      type test = {
        #nat: Nat;
        #text: Text
      }
    """
