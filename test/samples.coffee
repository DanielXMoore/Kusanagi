parser = require "../source/parser"

{writeFileSync} = require "fs"

describe 'Compiling samples', ->
  it "should compile simple example", ->
    # https://github.com/dfinity/motoko/blob/master/doc/modules/language-guide/examples/Alarm.mo
    exampleSource = """
      import Debug "mo:base/Debug"

      actor Alarm
        let n = 5
        var count = 0

        public shared func ring() : async ()
          Debug.print "Ring!"

        system func heartbeat() : async ()
          if count % n == 0
            await ring()

          count += 1
    """

    output = """
      import Debug "mo:base/Debug";

      actor Alarm {
        let n = 5;
        var count = 0;

        public shared func ring() : async () {
          Debug.print("Ring!");
        };

        system func heartbeat() : async () {
          if (count % n == 0) {
            await ring();
          };
          count += 1;
        }
      }
    """

    compiled = parser.parse(exampleSource)

    writeFileSync("out.txt", compiled)

    assert.equal compiled, output
