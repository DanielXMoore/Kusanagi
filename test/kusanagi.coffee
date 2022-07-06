parser = require "../source/kusanagi"

{readFileSync} = require "fs"

describe "Kusanagi", ->
  describe "Parsing Examples", ->
    [
      "Basic.ku"
    ].forEach (file) ->
      it file, ->
        assert parser.parse readFileSync("./test/examples/#{file}", "utf8")

  describe "Parsing .mo files", ->
    [
      "Alarm.mo"
      "heros.mo"
      # "JSON.mo" TODO: ;
      "Loop.mo"
      "Pub.mo"
      "Sub.mo"
      "Switch.mo"
      "TryCatch.mo"
      # "life/Grid.mo" TODO: else
      "life/Random.mo"
      "life/State.mo"
      "life/main.mo"
      # "uuid/Source.mo" TODO: ;
    ].forEach (file) ->

      it file, ->
        assert parser.parse readFileSync("./test/examples/#{file}", "utf8")
