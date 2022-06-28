parser = require "../source/motoko"

{readFileSync} = require "fs"

describe "Motoko Grammar", ->
  describe "examples", ->
    it "Alarm.mo", ->
      assert parser.parse readFileSync("./test/examples/Alarm.mo", "utf8")

    it "Pub.mo", ->
      assert parser.parse readFileSync("./test/examples/Pub.mo", "utf8")

    it "Sub.mo", ->
      assert parser.parse readFileSync("./test/examples/Sub.mo", "utf8")

    it "Heros.mo", ->
      assert parser.parse readFileSync("./test/examples/heros.mo", "utf8")

    it "life/Grid.mo", ->
      assert parser.parse readFileSync("./test/examples/life/Grid.mo", "utf8")

    it "life/Random.mo", ->
      assert parser.parse readFileSync("./test/examples/life/Random.mo", "utf8")

    it "life/State.mo", ->
      assert parser.parse readFileSync("./test/examples/life/State.mo", "utf8")

    it "life/main.mo", ->
      result = parser.parse readFileSync("./test/examples/life/main.mo", "utf8")

      assert.equal result.declarations[0].type, "actor"
      assert.equal result.declarations[0].id, "Life"
      assert.equal result.declarations[0].body.decs.length, 5

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
