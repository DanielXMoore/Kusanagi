{ compare } = require "./helper"

describe "chained comparison", ->
  it "expands to anded booleans", ->
    compare """
      1 < 2 < 3
    """, """
      1 < 2 and 2 < 3;
    """

  it "expands with a variety of operators", ->
    compare """
      1 < 2 <= 3 > 4 >= 5 == 6 != 7
    """, """
      1 < 2 and 2 <= 3 and 3 > 4 and 4 >= 5 and 5 == 6 and 6 != 7;
    """

  it "keeps arithmetic operators attached to the expressions", ->
    compare """
      1 + 2 < y <= 3 * 4 > 5 / 6 >= 7 % 8 == 9 ** 10 != 11
    """, """
      1 + 2 < y and y <= 3 * 4 and 3 * 4 > 5 / 6 and 5 / 6 >= 7 % 8 and 7 % 8 == 9 ** 10 and 9 ** 10 != 11;
    """

  it "type annotations have lower precedence", ->
    compare """
      1 < y: Bool != false
    """, """
      1 < y: Bool != false;
    """
