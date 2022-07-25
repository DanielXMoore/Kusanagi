parser = require "../source/kusanagi"

{readFileSync} = require "fs"

generate = require "../source/generate"

describe "Kusanagi", ->
  describe "Parsing Examples", ->
    [
      "Basic"
      "Full"
      "Hex"
      "Loop"
      "Math"
      "NestedObject"
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
        /// Inline comment
        #text: Text
      }

    """

  it "type binding in function application", ->
    assert.equal generate(parser.parse """
      let map = Map.RBTree<Key, Value>(Nat.compare)
    """), """
      let map = Map.RBTree<Key, Value>(Nat.compare)
    """

  it "type declaration", ->
    assert.equal generate(parser.parse """
      type Tree<X, Y> =
        #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>)
        #leaf
    """), """
      type Tree<X, Y> = {
        #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>);
        #leaf
      }
    """

  it "addition", ->
    assert.equal generate(parser.parse """
      let x = a + b
    """), """
      let x = a + b
    """

  it "unary operator in function application", ->
    assert.equal generate(parser.parse """
      x +b
    """), """
      x(+b)
    """

  it "comment between function application", ->
    assert.equal generate(parser.parse """
      x /*A*/ +b
    """), """
      x /*A*/(+b)
    """

  describe "func", ->
    it "simple func", ->
      assert.equal generate(parser.parse """
        func size() : Nat
          n
        """), """
        func size() : Nat {
          n
        }
      """

    it "with end of line comment", ->
      assert.equal generate(parser.parse """
        func size() : Nat // End of line comment!
          n
        """), """
        func size() : Nat // End of line comment!
        {
          n
        }
      """

    it "with inline comments", ->
      assert.equal generate(parser.parse """
        /* C0 */ func /* C1 */ size /* C2 */ () /* C3 */ : /* C4 */ Nat /* C5 */
          // C6
          n
      """), """
        /* C0 */ func /* C1 */ size /* C2 */ () /* C3 */ : /* C4 */ Nat /* C5 */
        {
          // C6
          n
        }
      """

  describe "loop", ->
    it "with while", ->
      assert.equal generate(parser.parse """
        loop
          x := 1 + 2
        while x < 1
      """), """
        loop {
          x := 1 + 2
        }
        while x < 1
      """

    it "with comments", ->
      assert.equal generate(parser.parse """
        loop /**/
          x := 1 + 2
        while /**/ x < 1
      """), """
        loop /**/
        {
          x := 1 + 2
        }
        while /**/ x < 1
      """
