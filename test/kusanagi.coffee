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

    it "associativity", ->
      compare """
        let x = a b, c d, e f
      """, """
        let x = a(b, c(d, e(f)));
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
        x(/*A*/ b);
      """

  it "type declaration", ->
    assert.equal generate(parser.parse """
      type Tree<X, Y> =
        #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>)
        #leaf
    """), """
      type Tree<X, Y> = {
        #node : (Color, Tree<X, Y>, (X, ?Y), Tree<X, Y>);
        #leaf;
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
          n;
        };
      """

    it "with end of line comment", ->
      assert.equal generate(parser.parse """
        func size() : Nat // End of line comment!
          n
        """), """
        func size() : Nat { // End of line comment!
          n;
        };
      """

    it "with inline comments", ->
      assert.equal generate(parser.parse """
        /* C0 */ func /* C1 */ size /* C2 */ () /* C3 */ : /* C4 */ Nat /* C5 */
          // C6
          n
      """), """
        /* C0 */ func /* C1 */ size /* C2 */ () /* C3 */ : /* C4 */ Nat { /* C5 */
          // C6
          n;
        };
      """

    it "=", ->
      compare """
        func A() = B
      """, """
        func A() = B;
      """

    it "= preserves comments and whitespace", ->
      compare """
        func A()/**/=/**/B
      """, """
        func A()/**/=/**/B;
      """

      compare """
        func A()/**/
        =
          /**/B
      """, """
        func A()/**/
        =
          /**/B;
      """

    it "without id", ->
      compare """
        func(idx) {}
      """, """
        func(idx) {};
      """

    it "anonymous func as an arguments parameter", ->
      compare """
        x(y, func (){{x=3}})
      """,
      """
        x(y, func (){{x=3}});
      """

    it "anonymous func as an arguments parameter without space after func", ->
      compare """
        x(y, func(){{x=3}})
      """,
      """
        x(y, func(){{x=3}});
      """

  describe "loop", ->
    it "with while", ->
      assert.equal generate(parser.parse """
        loop
          x := 1 + 2
        while x < 1
      """), """
        loop {
          x := 1 + 2;
        }
        while x < 1;
      """

    it "with comments", ->
      assert.equal generate(parser.parse """
        loop /**/
          x := 1 + 2
        while /**/ x < 1
      """), """
        loop { /**/
          x := 1 + 2;
        }
        while /**/ x < 1;
      """

  describe "type", ->
    describe "object", ->
      it "empty", ->
        compare """
          type X = {}
        """, """
          type X = {};
        """

      it "newline after equals", ->
        compare """
          type X =
            {}
        """, """
          type X =
            {};
        """

      it "maintains comments and newlines", ->
        compare """
          type X = { /* */
          }
        """, """
          type X = { /* */
          };
        """

      it "nested", ->
        compare """
          type Counter =
            topic : Text
            value : Nat
        """, """
          type Counter = {
            topic : Text;
            value : Nat;
          };
        """

      it "with braces", ->
        compare """
          type Counter2 = {
            topic : Text;
            value : Nat;
          };
        """, """
          type Counter2 = {
            topic : Text;
            value : Nat;
          };
        """

      it "with braces has optional semicolons", ->
        compare """
          type Counter2 = {
            topic : Text
            value : Nat
          };
        """, """
          type Counter2 = {
            topic : Text;
            value : Nat;
          };
        """

    describe "nullable", ->
      it "basic", ->
        compare """
          type nullable = ?Text
        """, """
          type nullable = ?Text;
        """

      it "keeps whitespace and comments", ->
        compare """
          type nullable =
                ?Text
        """, """
          type nullable =
                ?Text;
        """

        compare """
          type nullable=?Text
        """, """
          type nullable=?Text;
        """

        compare """
          type nullable /**/= /**/? /**/Text //
        """, """
          type nullable /**/= /**/? /**/Text; //
        """

    describe "variant", ->
      it "brace", ->
        compare """
          type test = {
            #nat: Nat
            #text: Text
          }
        """, """
          type test = {
            #nat: Nat;
            #text: Text;
          };
        """

      it "brace with optional semi-colons and inline comments", ->
        compare """
          type test = {
            #nat: Nat /**/ // Yo
            #text: Text /**/; // heyy
          }
        """, """
          type test = {
            #nat: Nat; /**/ // Yo
            #text: Text /**/; // heyy
          };
        """

      it "nested", ->
        compare """
          type test =
            #nat: Nat
            #text: Text
        """, """
          type test = {
            #nat: Nat;
            #text: Text;
          };
        """

      it "maintains newlines and whitespace", ->
        compare """
          type test = /**/
            #/**/nat: Nat
            #  text: Text
            #
            hi: Hi
        """, """
          type test = { /**/
            #/**/nat: Nat;
            #  text: Text;
            #
            hi: Hi;
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

    it "nullable",  ->
      compare """
        let aStudent =
          name = ?"John"
          id = ?1
          clas = ?Map.new<Text, ClassType>()
      """,
      """
        let aStudent = {
          name = ?"John";
          id = ?1;
          clas = ?Map.new<Text, ClassType>();
        };
      """

    it "object syntax", ->
      compare """
        let { ihash; nhash; thash; phash; bhash; lhash; calcHash } = Utils;
      """, """
        let { ihash; nhash; thash; phash; bhash; lhash; calcHash } = Utils;
      """

    it "object syntax indented", ->
      compare """
        let {
          ihash
          nhash
          thash
          phash
          bhash
          lhash
          calcHash
        } = Utils
      """, """
        let {
          ihash;
          nhash;
          thash;
          phash;
          bhash;
          lhash;
          calcHash;
        } = Utils;
      """

    it "object syntax keeps whitespace and comments", ->
      compare """
        let {
          ihash; /**/
             nhash;
          thash // A
          /* */phash
          /// Co
          bhash
          lhash
          calcHash
        } = Utils
      """, """
        let {
          ihash; /**/
             nhash;
          thash; // A
          /* */phash;
          /// Co
          bhash;
          lhash;
          calcHash;
        } = Utils;
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

    it "should allow optional commas", ->
      compare """
        let x = [
          1
          2,
          3
        ]
        """, """
        let x = [
          1,
          2,
          3,
        ];
      """

    it "should allow adding additional comma separated items per line", ->
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

  describe "object", ->
    it "should have optional semi-colons with braces", ->
      compare """
        func () {
          {
            name = val[idx].name
            value = clone(val[idx].value)
            immutable = val[idx].immutable
          }
        }
      """,
      """
        func () {
          {
            name = val[idx].name;
            value = clone(val[idx].value);
            immutable = val[idx].immutable;
          };
        };
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
        3, 4,
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
        3, 4,
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
        3, 4,
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

    # TODO: Nice to have, but need to work through the implications
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
          X();
        }
        catch e {
          Y();
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
        /* */ try { // C
          /// A
          X();
        }
        catch /**/ e { /* */
          Y(); // B
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
            assert(false);
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
        switch(/**/ rand.read 2) { /**/ //
          /// AA
          case #ok(bs)  bs;
          case /**/ #eof(bs) bs;
          case #err(_) {
            assert(false);
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
            count += 1;
          };

          public func read() : async Nat {
            count;
          };

          public func bump() : async Nat {
            count += 1;
            count;
          };
        };

      """

  describe "binassign", ->
    it "basic", ->
      compare """
        x += 1
      """, """
        x += 1;
      """

    it "allows newlines", ->
      compare """
        x +=
            1
      """, """
        x +=
            1;
      """

    it "comments and whitespace", ->
      compare """
        x /**/+= /**/1
      """, """
        x /**/+= /**/1;
      """

  describe "class", ->
    it "basic", ->
      compare """
        class X() {}
      """, """
        class X() {};
      """

    it "=", ->
      compare """
        class X() = Y {}
      """, """
        class X() = Y {};
      """

    it "= maintains whitespace and comments", ->
      compare """
        class X()/**/ = /**/Y/**/ {}
      """, """
        class X()/**/ = /**/Y/**/ {};
      """

      compare """
        class X()

        /**/ = /**/

            Y/**/

              {
                  //
              }
      """, """
        class X()

        /**/ = /**/

            Y/**/

              {
                  //
              };
      """

  describe "do", ->
    it "basic", ->
      compare """
        do {}
      """, """
        do {};
      """

    it "option", ->
      compare """
        do ? {}
      """, """
        do ? {};
      """

    it "option comments and whitespace", ->
      compare """
        /**/do /**/?/***/
          {/**/
        //
             /**/}
      """, """
        /**/do /**/?/***/
          {/**/
        //
             /**/};
      """

  describe "for", ->
    it "basic", ->
      compare """
        for i in x
          Debug.print i
      """, """
        for (i in x) {
          Debug.print(i);
        };
      """

    it "nested", ->
      compare """
        for i in grid.keys()
          for j in grid[i].keys()
            dst.set i, j, nextCell i, j
      """, """
        for (i in grid.keys()) {
          for (j in grid[i].keys()) {
            dst.set(i, j, nextCell(i, j));
          };
        };
      """

    it "maintains comments and whitespace", ->
      compare """
        for/**/i/**/in/**/x/**/
          Debug.print i
      """, """
        for/**/(i/**/in/**/x) {/**/
          Debug.print(i);
        };
      """

  describe "if", ->
    it "basic", ->
      compare """
        if x
          y
      """, """
        if(x) {
          y;
        };
      """

    it "else", ->
      compare """
        if x
          y
        else
          z
      """, """
        if(x) {
          y;
        }
        else {
          z;
        };
      """

    it "with braces", ->
      compare """
        if (x) {
          x;
          y;
          z;
        }
      """, """
        if (x) {
          x;
          y;
          z;
        };
      """

    it "with braces", ->
      compare """
        if x {
          y=1;
        }
          z
      """, """
        if(x {
          y=1;
        }) {
          z;
        };
      """

    it "maintains whitespace and comments", ->
      compare """
        if /**/ x //
          y
        else
          z
      """, """
        if(/**/ x) { //
          y;
        }
        else {
          z;
        };
      """

    it "should work with tight comment", ->
      compare """
        if/**/x
          y
      """, """
        if(/**/x) {
          y;
        };
      """

  describe "keyword expressions", ->
    describe "return", ->
      keyword = "return"

      it "basic", ->
        compare """
          #{keyword} true
        """,
        """
          #{keyword} true;
        """

      it "maintains newlines and indent", ->
        compare """
          #{keyword}
                true
        """,
        """
          #{keyword}
                true;
        """

      it "doesn't nest, just one statement then another", ->
        compare """
          return
            x
            true
        """,
        """
          return
            x;
            true;
        """

      # TODO: nice to have
      it.skip "shouldn't return following line unless nested / indented", ->
        compare """
          return
          x
        """,
        """
          return;
          x;
        """

      it "maintains comments", ->
        compare """
          #{keyword}/**/true
        """,
        """
          #{keyword}/**/true;
        """

    """
      assert
      async
      await
      debug
      ignore
      throw
    """.split("\n").forEach (keyword) ->
      describe keyword, ->
        it "basic", ->
          compare """
            #{keyword} true
          """,
          """
            #{keyword} true;
          """

        it "maintains newlines and indent", ->
          compare """
            #{keyword}
                  true
          """,
          """
            #{keyword}
                  true;
          """

        it "nested", ->
          compare """
            #{keyword}
              x
              true
          """,
          """
            #{keyword} {
              x;
              true;
            };
          """

        it "maintains comments", ->
          compare """
            #{keyword}/**/true
          """,
          """
            #{keyword}/**/true;
          """

  describe "while", ->
    it "basic", ->
      compare """
        while x > 1
          x -= 1
      """, """
        while(x > 1) {
          x -= 1;
        };
      """

    it "maintains whitespace and comments", ->
      compare """
        while/**/x >
         1 // A
          ///
          x -= 1 // B
      """, """
        while(/**/x >
         1) { // A
          ///
          x -= 1; // B
        };
      """

  describe "take", ->
    it "adds switch with a default value, no parens", ->
      compare """
        take x, 0
      """, """
        switch(x){case(null){0};case(?val){val}};
      """

    it "adds switch with a default value, with parens", ->
      compare """
        take(x, 0)
      """, """
        switch(x){case(null){0};case(?val){val}};
      """

  describe "match", ->
    it "adds switch with case, no parens", ->
      compare """
        let x: Nat = match x, #nat(val), 0
      """, """
        let x: Nat = switch(x){case(#nat(val)){x};case(_){0}};
      """

    it "adds switch with case, with parens", ->
      compare """
        let x: Nat = match(x, #nat(val), 0)
      """, """
        let x: Nat = switch(x){case(#nat(val)){x};case(_){0}};
      """

    it "works with expressions", ->
      compare """
        let x = match aResult, #ok(aResult), return #err(debug_show(aResult))
      """, """
        let x = switch(aResult){case(#ok(aResult)){aResult};case(_){return #err(debug_show(aResult))}};
      """

  describe "null soak", ->
    it "should convert to do {}", ->
      compare """
        student.classes?.get(classID)
      """, """
        do?{student.classes!.get(classID)};
      """

  describe "arrow functions", ->
    it "basic", ->
      compare """
        (x: Nat) =>
          x + 1
      """, """
        func (x: Nat) {
          x + 1;
        };
      """

    it "in let", ->
      compare """
        let addOne : (Nat) -> Nat = (x: Nat) =>
          x + 1
      """, """
        let addOne : (Nat) -> Nat = func (x: Nat) {
          x + 1;
        };
      """

    it "with types", ->
      compare """
        let addOne : (Nat) -> Nat = <X>(x: Nat) : Nat =>
          x + 1
      """, """
        let addOne : (Nat) -> Nat = func <X>(x: Nat) : Nat {
          x + 1;
        };
      """

  describe "backtick escapes", ->
    it "basic", ->
      compare """
        `literal text !!{}`
      """, """
        literal text !!{}
      """

    it "prefix", ->
      compare """
        `+++`b
      """, """
        +++b;
      """

    it "func after id", ->
      compare """
        func f`*`()
          1
      """, """
        func f*() {
          1;
        };
      """

    it "func before id", ->
      compare """
        func `*`f()
          1
      """, """
        func *f() {
          1;
        };
      """

    it "indented", ->
      compare """
        func f()
          `//
            let x = 1
          //`
          y
      """, """
        func f() {
          //
            let x = 1
          //
          y;
        };
      """

  describe "new features", ->
    it "take with null soaks", ->
      compare """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
          return #ok take(student.classes?.get(classID), return #err "not found")
      """, """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
          return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
        };
      """

    it "take with null soaks", ->
      compare """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
          return #ok(take student.classes?.get(classID), return #err "not found")
      """, """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
          return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
        };
      """

    it "take with null soaks", ->
      compare """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
          return #ok take student.classes?.get(classID), return #err "not found"
      """, """
        func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
          return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
        };
      """
