parser = require "../source/kusanagi"

{readFileSync} = require "fs"

generate = require "../source/generate"

compare = (src, result) ->
  assert.equal generate(parser.parse(src)), result

throws = (src) ->
  assert.throws ->
    generate(parser.parse(src))

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
      };

    """

  describe "function application", ->
    it "should apply with parens", ->
      compare """
        let x = a(b, c)
      """, """
        let x = a(b, c);
      """

    it "should apply without parens", ->
      compare """
        let x = a b, c
      """, """
        let x = a(b, c);
      """

    it "type binding", ->
      assert.equal generate(parser.parse """
        let map = Map.RBTree<Key, Value>(Nat.compare)
      """), """
        let map = Map.RBTree<Key, Value>(Nat.compare);
      """

    it "applying on argument with unary operator", ->
      assert.equal generate(parser.parse """
        x +b
      """), """
        x(+b);
      """

    it "comment between function application", ->
      assert.equal generate(parser.parse """
        x /*A*/ b
      """), """
        x /*A*/(b);
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
      };
    """

  it "addition", ->
    assert.equal generate(parser.parse """
      let x = a + b
    """), """
      let x = a + b;
    """

  describe "func", ->
    it "simple func", ->
      assert.equal generate(parser.parse """
        func size() : Nat
          n
        """), """
        func size() : Nat {
          n
        };
      """

    it "with end of line comment", ->
      assert.equal generate(parser.parse """
        func size() : Nat // End of line comment!
          n
        """), """
        func size() : Nat // End of line comment!
        {
          n
        };
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
        };
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
        while x < 1;
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
        while /**/ x < 1;
      """

  describe "type", ->
    it "object", ->
      # Empty
      compare """
        type X = {}
      """, """
        type X = {};
      """

      # With newline after equals
      compare """
        type X =
          {}
      """, """
        type X =
          {};
      """

      # Empty with comments
      compare """
        type X = { /* */
        }
      """, """
        type X = { /* */
        };
      """

    it "nullary", ->
      compare """
        type X = ()
      """, """
        type X = ();
      """

      # Keeps whitespace
      compare """
        type X = (


        )
      """, """
        type X = (


        );
      """

    it "binding", ->
      compare """
        type X<A,B> = Y<B,A>
      """, """
        type X<A,B> = Y<B,A>;
      """

    it "tuple", ->
      compare """
        type X = (a, b, c)
      """, """
        type X = (a, b, c);
      """

      # With comments and whitespace
      compare """
        type X = ( /* A */ a, /* B */
             /// D
         b, /* C*/c)
      """, """
        type X = ( /* A */ a, /* B */
             /// D
         b, /* C*/c);
      """

    it "array", ->
      compare """
        type X = [A]
      """, """
        type X = [A];
      """

      # With comments and whitespace
      compare """
        type /* X */ X =  /* E */        [A]
      """, """
        type /* X */ X =  /* E */        [A];
      """

      # With newline after equals
      compare """
        type X =
         /// BB
           [A]
      """, """
        type X =
         /// BB
           [A];
      """

    it "newline after equals", ->
      compare """
        type X =
          ()
      """, """
        type X =
          ();
      """

    it "nullary with comments", ->
      compare """
        type X = (
          // Yo
        )
      """, """
        type X = (
          // Yo
        );
      """

      compare """
        type X = ( /* */
        /* */)
      """, """
        type X = ( /* */
        /* */);
      """

    describe "and / or", ->
      it "basic", ->
        compare """
          type A = X and Y or Z
        """, """
          type A = X and Y or Z;
        """

      it "keeps comments and whitespace", ->
        compare """
          type X = Y   /**/or /**/Z
        """, """
          type X = Y   /**/or /**/Z;
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
          Z;
        """

    describe "funcs", ->
      it "Func sort", ->
        compare """
          type X = shared query () -> ()
        """, """
          type X = shared query () -> ();
        """

        # With comments
        compare """
          type X = shared /* heyyy */ query () -> ()
        """, """
          type X = shared /* heyyy */ query () -> ();
        """

      it "newlines after arrow", ->
        # With newlines after func arrow
        compare """
          type X = () ->
            ()
        """, """
          type X = () ->
            ();
        """

      it "newlines before arrow", ->
        # With newlines after func arrow
        compare """
          type X = ()
           ->()
        """, """
          type X = ()
           ->();
        """

  describe "let", ->
    it "should keep whitespace and comments", ->
      compare """
          let   /**/  x  /* */ = /**/ x
        """, """
          let   /**/  x  /* */ = /**/ x;
        """

    it "basic", ->
      compare """
        let rand = Random.new()
      """, """
        let rand = Random.new();
      """

  describe "var", ->
    it "should keep whitespace and comments", ->
      compare """
          var   /**/  x  /* */ = /**/ b
        """, """
          var   /**/  x  /* */ = /**/ b;
        """

  describe "nested array", ->
    it "should add commas", ->
      compare """
        let x = [
          1
          2
          3
        ]
        """, """
        let x = [
          1,
          2,
          3,
        ];
      """

    # TODO: nice to have
    it.skip "should allow optional commas", ->
      compare """
        let x = [
          1
          2, 3
        ]
        """, """
        let x = [
          1,
          2, 3,
        ];
      """

    it "should keep inline comments", ->
      compare """
        let x = [
          /// A
          1 // hi
          /// B
          2 /* */
          /// C
          3
        ]
      """, """
        let x = [
          /// A
          1, // hi
          /// B
          2, /* */
          /// C
          3,
        ];
      """

    it "should maintain whitespace and comments before and after var", ->
      compare """
        let x = [ //

             /**/ var /* */

             // A
          1
          2
          3
        ]
        """, """
        let x = [ //

             /**/ var /* */

             // A
          1,
          2,
          3,
        ];
      """

  describe "comma separated array", ->
    it "should be lenient with indentation", ->
      compare """
        let x = [ 1,
          2,
        3, 4
        ]
        """, """
        let x = [ 1,
          2,
        3, 4
        ];
      """

    it "should maintain comments", ->
      compare """
        let x = [ /**/1, // a
          /** */2,
        /// E
        3, 4
        ]
        """, """
        let x = [ /**/1, // a
          /** */2,
        /// E
        3, 4
        ];
      """

    it "should maintain comments around var", ->
      compare """
        let x = [
          // B
          var/**/1, // a
          /** */2,
        /// E
        3, 4
        ]
        """, """
        let x = [
          // B
          var/**/1, // a
          /** */2,
        /// E
        3, 4
        ];
      """

  describe "index", ->
    it "should keep whitespace and comments", ->
      compare """
        let x = a[
          /**/1   /*  */]
        """, """
        let x = a[
          /**/1   /*  */];
      """

    it "should convert to function application when preceded by whitespace", ->
      compare """
        let x = a [1]
      """, """
        let x = a([1]);
      """

  describe "projection", ->
    it "should keep whitespace and comments", ->
      compare """
        let x = a. //
          /**/   /*  */
          b
      """, """
        let x = a. //
          /**/   /*  */
          b;
      """

    it "should allow whitespace and comments before the '.'", ->
      compare """
        let x = a /**/ .b
      """, """
        let x = a /**/ .b;
      """

  describe "comments", ->
    it "should work when a comment is trailing before EOF", ->
      compare """
        var x = 1 // The x var
      """, """
        var x = 1; // The x var
      """

  describe "tuple pattern", ->
    it "basic", ->
      compare """
        let (a, b, c) = x
      """, """
        let (a, b, c) = x;
      """

    it "should work without spaces", ->
      compare """
        let (a,b,c)=x
      """, """
        let (a,b,c)=x;
      """

    it "should keep whitespace and comments", ->
      compare """
        let /*a*/( /**/ a, /**/ b, c) = x
      """, """
        let /*a*/( /**/ a, /**/ b, c) = x;
      """

    # TODO: Not sure about this, may be ambiguous
    it.skip "should work without parens", ->
      compare """
        let a, b, c = x
      """, """
        let (a, b, c) = x;
      """

  describe "tuple expression", ->
    it "basic", ->
      compare """
        let x = (a, b, c)
      """, """
        let x = (a, b, c);
      """

    it "maintains whitespace", ->
      compare """
        let x=(a,b,c)
      """, """
        let x=(a,b,c);
      """

    it "maintains comments", ->
      compare """
        let x=(a,

        /* */b, //

        /*  */c)
      """, """
        let x=(a,

        /* */b, //

        /*  */c);
      """

    # TODO: Nice to have
    it.skip "paren-less", ->
      compare """
        let x = a, b, c
      """, """
        let x = (a, b, c);
      """

  describe "try catch", ->
    it "basic", ->
      compare """
        try
          X()
        catch e
          Y()
      """, """
        try {
          X()
        }
        catch e {
          Y()
        };
      """

    it "maintains whitespace and comments", ->
      compare """
        /* */ try // C
          /// A
          X()
        catch /**/ e /* */
          Y() // B
      """, """
        /* */ try // C
        {
          /// A
          X()
        }
        catch /**/ e /* */
        {
          Y() // B
        };
      """

  describe "switch", ->
    it "basic", ->
      compare """
        switch rand.read 2
          case #ok(bs)  bs
          case #eof(bs) bs
          case #err(_)
            assert(false)
      """, """
        switch(rand.read 2) {
          case #ok(bs)  bs;
          case #eof(bs) bs;
          case #err(_) {
            assert(false)
          };
        };
      """

    it "maintains whitespace and comments", ->
      compare """
        switch /**/ rand.read 2 /**/ //
          /// AA
          case #ok(bs)  bs
          case /**/ #eof(bs) bs
          case #err(_)
            assert(false)
      """, """
        switch /**/(rand.read 2) { /**/ //
          /// AA
          case #ok(bs)  bs;
          case /**/ #eof(bs) bs;
          case #err(_) {
            assert(false)
          };
        };
      """

  describe "assert", ->
    it "basic", ->
      compare """
        assert false
      """, """
        assert false;
      """

    it "maintains whitespace and comments", ->
      compare """
        assert /**/
         /* */ // A
        (false)
      """, """
        assert /**/
         /* */ // A
        (false);
      """

  describe "async", ->
    it "basic", ->
      compare """
        async false
      """, """
        async false;
      """

    it "maintains whitespace and comments", ->
      compare """
        async /**/
         /* */ // A
        (false)
      """, """
        async /**/
         /* */ // A
        (false);
      """

    it "obj sort", ->
      # TODO: Not sure about this example
      compare """
        async module {}
      """, """
        async module {};
      """

  describe "actor", ->
    it "basic", ->
      compare """
        actor class Counter(init : Nat) {}
      """, """
        actor class Counter(init : Nat) {};
      """

    it "shouldn't compile without a body", ->
      throws """
        actor class Counter(init : Nat)
      """

    it "should maintain whitespace and comments", ->
      compare """
        // h
        /**/actor/**/class/**/Counter(/**/init : Nat) {/**/}
      """, """
        // h
        /**/actor/**/class/**/Counter(/**/init : Nat) {/**/};
      """

    it "full example", ->
      compare """
        actor class Counter(init : Nat)
          var count = init

          public func inc() : async ()
            count += 1

          public func read() : async Nat
            count

          public func bump() : async Nat
            count += 1
            count

      """, """
        actor class Counter(init : Nat) {
          var count = init;

          public func inc() : async () {
            count += 1
          };

          public func read() : async Nat {
            count
          };

          public func bump() : async Nat {
            count += 1;
            count
          }
        };

      """
