{parse, generate, compile} = require "../source/main"

describe "main", ->
  it "parses", ->
    parse """
      x = 1
    """

  it "compiles", ->
    result = compile """
      x = 1
    """

    assert.equal result, "let x = 1;"

  it "exports generate", ->
    assert.equal generate(parse "x = 1"), "let x = 1;"
