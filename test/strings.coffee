{ compare, throws } = require "./helper"

describe "string", ->
  it "basic", ->
    compare """
      x = "out"
    """, """
      let x = "out";
    """

  it "multiline", ->
    compare """
      x = "
      123
      "
    """, """
      let x = "\\n123\\n";
    """
