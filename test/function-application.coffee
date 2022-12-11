{ testCase } = require "./helper"

describe "function application", ->
  testCase """
    name starts with not
    ---
    M.not_()
    ---
    M.not_();
  """
