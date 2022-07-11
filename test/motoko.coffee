parser = require "../source/motoko"

{readFileSync} = require "fs"

describe "Motoko Grammar", ->
  describe "examples", ->
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

  it "should parse imports", ->
    result = parser.parse """
      import Debug "mo:base/Debug";
      import Option "mo:base/Option";

      actor Alarm {
        let n = 5;
        var count = 0;

        public shared func ring() : async () {
          Debug.print("Ring!");
        };
      }
    """

    assert.deepEqual result.imports, [
      ["\"mo:base/Debug\"", "Debug"]
      ["\"mo:base/Option\"", "Option"]
    ]
