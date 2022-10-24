{ compare, throws } = require "./helper"

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

  it "shorthand", ->
    compare """
      rand = Random.new()
    """, """
      let rand = Random.new();
    """

  it "should allow ids that begin with underscores", ->
    compare """
      let __a = 3
    """, """
      let __a = 3;
    """

  it "should allow underscore pat", ->
    compare """
      let _ = 3
    """, """
      let _ = 3;
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

  it "nested object syntax", ->
    compare """
      import AccountIdentifier "mo:principalmo/AccountIdentifier"

      module

        let debug_channel =
          verify_escrow = true
          verify_sale = false
          ensure = false
          invoice = false
          end_sale = false
          market = false
          royalties = false
          offers = false
          escrow = false
          withdraw_escrow = false
          withdraw_sale = false
          withdraw_reject = false
          bid = false
    """, """
      import AccountIdentifier "mo:principalmo/AccountIdentifier";

      module {

        let debug_channel = {
          verify_escrow = true;
          verify_sale = false;
          ensure = false;
          invoice = false;
          end_sale = false;
          market = false;
          royalties = false;
          offers = false;
          escrow = false;
          withdraw_escrow = false;
          withdraw_sale = false;
          withdraw_reject = false;
          bid = false;
        };
      };
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
