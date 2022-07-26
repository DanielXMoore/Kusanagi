parser = require "../source/kusanagi"

{readFileSync} = require "fs"

generate = require "../source/generate"

compare = (src, result) ->
  assert.equal generate(parser.parse(src)), result

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

  describe "type", ->
    it "object", ->
      # Empty
      compare """
        type X = {}
      """, """
        type X = {}
      """

      # With newline after equals
      compare """
        type X =
          {}
      """, """
        type X =
          {}
      """

      # Empty with comments
      compare """
        type X = { /* */
        }
      """, """
        type X = { /* */
        }
      """

    it "nullary", ->
      compare """
        type X = ()
      """, """
        type X = ()
      """

      # Keeps whitespace
      compare """
        type X = (


        )
      """, """
        type X = (


        )
      """

    it "binding", ->
      compare """
        type X<A,B> = Y<B,A>
      """, """
        type X<A,B> = Y<B,A>
      """

    it "tuple", ->
      compare """
        type X = (a, b, c)
      """, """
        type X = (a, b, c)
      """

      # With comments and whitespace
      compare """
        type X = ( /* A */ a, /* B */
             /// D
         b, /* C*/c)
      """, """
        type X = ( /* A */ a, /* B */
             /// D
         b, /* C*/c)
      """

    it "array", ->
      compare """
        type X = [A]
      """, """
        type X = [A]
      """

      # With comments and whitespace
      compare """
        type /* X */ X =  /* E */        [A]
      """, """
        type /* X */ X =  /* E */        [A]
      """

      # With newline after equals
      compare """
        type X =
         /// BB
           [A]
      """, """
        type X =
         /// BB
           [A]
      """

    it "newline after equals", ->
      compare """
        type X =
          ()
      """, """
        type X =
          ()
      """

    it "nullary with comments", ->
      compare """
        type X = (
          // Yo
        )
      """, """
        type X = (
          // Yo
        )
      """

      compare """
        type X = ( /* */
        /* */)
      """, """
        type X = ( /* */
        /* */)
      """

    describe "and / or", ->
      it "basic", ->
        compare """
          type A = X and Y or Z
        """, """
          type A = X and Y or Z
        """

      it "keeps comments and whitespace", ->
        compare """
          type X = Y   /**/or /**/Z
        """, """
          type X = Y   /**/or /**/Z
        """

      it "should keep newlines", ->
        compare """
          type X =
           Y
            or
          Z
        """, """
          type X =
           Y
            or
          Z
        """

    describe "funcs", ->
      it "Func sort", ->
        compare """
          type X = shared query () -> ()
        """, """
          type X = shared query () -> ()
        """

        # With comments
        compare """
          type X = shared /* heyyy */ query () -> ()
        """, """
          type X = shared /* heyyy */ query () -> ()
        """

      it "newlines after arrow", ->
        # With newlines after func arrow
        compare """
          type X = () ->
            ()
        """, """
          type X = () ->
            ()
        """

      it "newlines before arrow", ->
        # With newlines after func arrow
        compare """
          type X = ()
           ->()
        """, """
          type X = ()
           ->()
        """

  describe "let", ->
    it "should keep whitespace and comments", ->
      compare """
          let   /**/  x  /* */ = /**/ x
        """, """
          let   /**/  x  /* */ = /**/ x
        """

  describe "var", ->
    it "should keep whitespace and comments", ->
      compare """
          var   /**/  x  /* */ = /**/ b
        """, """
          var   /**/  x  /* */ = /**/ b
        """
