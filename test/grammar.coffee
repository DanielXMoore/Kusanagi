parser = require "../source/grammar"

{readFileSync} = require "fs"

describe "Motoko Grammar", ->
  it "should parse simple .mo files", ->
    assert parser.parse readFileSync("./test/examples/Alarm.mo", "utf8")

  it "should parse more complex .mo files", ->
    assert parser.parse readFileSync("./test/examples/heros.mo", "utf8")

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
      ["mo:base/Debug", "Debug"]
      ["mo:base/Option", "Option"]
    ]
