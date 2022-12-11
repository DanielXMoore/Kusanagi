{ testCase } = require "./helper"

describe "function application", ->
  testCase """
    named not
    ---
    M.not()
    ---
    M.not();
  """
