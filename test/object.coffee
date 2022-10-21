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
