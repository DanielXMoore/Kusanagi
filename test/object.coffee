{ compare, throws } = require "./helper"

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

  it "nested syntax inside braces", ->
    compare """
      let x = {
        a =
          b = 2
      }
    """, """
      let x = {
        a = {
          b = 2;
        };
      };
    """

  it "nested syntax", ->
    compare """
      let x =
        a =
          b = 2
    """, """
      let x = {
        a = {
          b = 2;
        };
      };
    """

  describe "spreads", ->
    it "no fields", ->
      compare """
        let x = {
          ...a
          ...b
        }
      """, """
        let x = {
          a and
          b
        };
      """

    it "with", ->
      compare """
        let x = {
          ...a
          b = 1
        }
      """, """
        let x = {
          a with
          b = 1;
        };
      """

    it "multiple with", ->
      compare """
        let x = {
          ...a
          ...b
          c = 1
          d = 2
        }
      """, """
        let x = {
          a and
          b with
          c = 1;
          d = 2;
        };
      """

    it "nested syntax", ->
      compare """
        let x =
          ...a
          b =
            c = 2
      """, """
        let x = {
          a with
          b = {
            c = 2;
          };
        };
      """

    it "nested syntax inside braces", ->
      compare """
        let x = {
          ...a
          b =
            c = 2
        }
      """, """
        let x = {
          a with
          b = {
            c = 2;
          };
        };
      """

    it "multiple nesting", ->
      compare """
        let x =
          ...a
          b =
            ...c
            d =
              e = 2
      """, """
        let x = {
          a with
          b = {
            c with
            d = {
              e = 2;
            };
          };
        };
      """
