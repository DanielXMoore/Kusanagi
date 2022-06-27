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
      assert.equal result.declarations[0].body.length, 5

      assert.deepEqual JSON.parse(JSON.stringify(result.declarations[0])), {"id":"Life","type":"actor","body":[{"vis":"","stab":"","dec":{"type":"let","pat":"state","exp":{"type":"do","block":{"type":"block","decs":[{"type":"let","pat":"rand","exp":{"type":"exppost","base":"Random","rest":[{"type":"projection","id":"new"},{"type":"application","fnArgs":{"type":"parens","exps":[]}}]}},{"type":"exppost","base":"State","rest":[{"type":"projection","id":"new"},{"type":"application","fnArgs":{"type":"parens","exps":[{"type":"exppost","base":"6","rest":[{"type":"application","fnArgs":"4"}]},{"type":"func","shared":"","pat":["i","j"],"body":{"type":"block","decs":[{"type":"expbin","exps":[{"type":"exppost","base":"rand","rest":[{"type":"projection","id":"next"},{"type":"application","fnArgs":{"type":"parens","exps":[]}}]},"%",{"type":"expbin","exps":["2","==","1"]}]}]}}]}}]}]}}}},{"vis":"","stab":"","dec":{"type":"var","id":"cur","exp":{"type":"exppost","base":"Grid","rest":[{"type":"projection","id":"Grid"},{"type":"application","fnArgs":{"type":"parens","exps":["state"]}}]}}},{"vis":"","stab":"","dec":{"type":"var","id":"nxt","exp":{"type":"exppost","base":"Grid","rest":[{"type":"projection","id":"Grid"},{"type":"application","fnArgs":{"type":"parens","exps":[{"type":"exppost","base":"State","rest":[{"type":"projection","id":"new"},{"type":"application","fnArgs":{"type":"parens","exps":[{"type":"exppost","base":"cur","rest":[{"type":"projection","id":"size"},{"type":"application","fnArgs":{"type":"parens","exps":[]}}]},{"type":"func","shared":"","pat":["i","j"],"body":{"type":"block","decs":["false"]}}]}}]}]}}]}}},{"vis":"public","stab":"","dec":{"type":"func","shared":"","id":"next","pat":[],"body":{"type":"block","decs":[{"type":"exppost","base":"cur","rest":[{"type":"projection","id":"next"},{"type":"application","fnArgs":{"type":"parens","exps":["nxt"]}}]},{"type":"let","pat":"temp","exp":"cur"},{"type":"binassign","base":"cur","op":":=","exp":"nxt"},{"type":"binassign","base":"nxt","op":":=","exp":"temp"},{"type":"exppost","base":"cur","rest":[{"type":"projection","id":"toText"},{"type":"application","fnArgs":{"type":"parens","exps":[]}}]}]}}},{"vis":"public","stab":"","dec":{"type":"func","shared":["query",[" "],null],"id":"current","pat":[],"body":{"type":"block","decs":[{"type":"exppost","base":"cur","rest":[{"type":"projection","id":"toText"},{"type":"application","fnArgs":{"type":"parens","exps":[]}}]}]}}}]}

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
