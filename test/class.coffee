{ testCase, throws } = require "./helper"

describe "class", ->
  testCase """
    basic
    ---
      class X() {}
    ---
      class X() {};
  """

  testCase """
    =
    ---
    class X() = Y {}
    ---
    class X() = Y {};
  """

  testCase """
    = maintains whitespace and comments
    ---
    class X()/**/ = /**/Y/**/ {}
    ---
    class X()/**/ = /**/Y/**/ {};
  """

  testCase """
    maintains whitespace and comments
    ---
    class X()

      /**/ = /**/

          Y/**/

            {
                //
            }
    ---
    class X()

      /**/ = /**/

          Y/**/

            {
                //
            };
  """

  it "throws when named a reserved word", ->
    throws """
      class not() {}
    """
