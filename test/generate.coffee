assert = require "assert"
{parse} = require "../source/kusanagi"
generate = require "../source/generate"

{readFileSync} = require "fs"

describe "generate", ->
  it "should generate Motoko code from basic example", ->
    ast = parse(readFileSync("./test/examples/Basic.ku", "utf8"))
    assert ast

    assert.equal generate(ast), """
      import State "State";

      module {
        public class Grid(state : State.State) {
          let grid = state;

          let n = grid.size();

          public func size() : Nat {
            n;
          };

          func nextCell(i : Nat, j : Nat) : State.Cell {
            let l : Nat = living(i, j);
            if(get(i, j)) {
              l == 2 or l == 3;
            }
            else {
              l == 3;
            };
          };

          func next(dst : Grid) {
            for (i in grid.keys()) {
              let cool = true;

              for (j in grid[i].keys()) {
                let yo = "wat";
                dst.set(i, j, nextCell(i, j));
              };
            };
          }
        }
      };

    """

  it "should generate full example from full example", ->
    ast = parse(readFileSync("./test/examples/Full.ku", "utf8"))
    assert ast

    assert.equal generate(ast), """
      import Debug "mo:base/Debug";

      /* /* Nested comment */ */

      // Nested syntax
      type Counter = {
        topic : Text;
        value : Nat;
      };

      // Object syntax
      type Counter2 = {
        topic : Text;
        value : Nat;
      };

      module {
        public class Grid(state : State.State) {
          let grid = state;

          let hex = 0x321.123;

          let n = grid.size();

          public func size() : Nat {
            n;
          };

          func nextCell(i : Nat, j : Nat) : State.Cell {
            let l : Nat = living(i, j);
            if(get(i, j)) {
              l == 2 or l == 3;
            }
            else {
              l == 3;
            };
          };

          func next(dst : Grid) {
            for (i in grid.keys()) {
              let cool = true;

              for (j in grid[i].keys()) {
                let yo = "wat"; // Comment at EOS
                dst.set(i, j, nextCell(i, j));
              };
            };
          };

          func tryCatch() : () {
            try {
              Debug.print "Ring!"; /* Comment at EOS */
            }
            catch e {
              Debug.print "!"; /* /* Nested Comment at EOS */ */ // Also regular comment at EOS
            };
          };

          public func setClockSequence(seq : ?Nat16) {
            var s : Nat16 = switch(seq) {
              case null {
                let bs = switch(rand.read 2) {
                  case #ok(bs)  bs;
                  case #eof(bs) bs;
                  case #err(_) {
                    assert(false);
                    [];
                  };
                };

                nat8to16(bs[0]) << 8 | nat8to16(bs[1]);
              };

              case ? s {
                s;
              };
            };
          };

          public func nestedObject() {
            var o = {
              x = 7;
              y = 3;
              z = {
                a = 34
              }
            };
          };

          public func nestedArray() {
            var a = [ var
              1,
              2,
              3,
            ];
          }
        }
      };

      /* Trailing comments */
      // Trailing comments

    """
