{ testCase } = require "./helper"

describe "examples", ->
  testCase """
    https://github.com/DanielXMoore/Kusanagi/issues/16
    ---
    import State "State"

    module
      public class Grid(state : State.State)

        let #Text(thirdPublication) : Candy.CandyValue =  switch(match(handled_events.getOpt(1), ?val, #Text("was null")))
          case(#Text(val))
            #Text(val)
          case(#Class(val))
            #Text(match(Properties.getClassProperty(#Class(val),"id"),?val, {name ="Not found"}).name)
          case(_)
            #Text("not a class")
    ---
    import State "State";

    module {
      public class Grid(state : State.State) {
        let #Text(thirdPublication) : Candy.CandyValue = switch (match(handled_events.getOpt(1), ?val, #Text("was null"))) {
          case (#Text(val)) {
            #Text(val);
          };
          case (#Class(val)) {
            #Text(match(Properties.getClassProperty(#Class(val), "id"), ?val, { name = "Not found"; }).name);
          };
          case (_) {
            #Text("not a class");
          };
        };
      };
    };
  """
