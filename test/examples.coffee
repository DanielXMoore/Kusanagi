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

        let #Text(thirdPublication) : Candy.CandyValue =  switch(switch(handled_events.getOpt(1)){case(?val){val};case(_){#Text("was null")}}) {
          case(#Text(val)) {
            #Text(val);
          };
          case(#Class(val)) {
            #Text((switch(Properties.getClassProperty(#Class(val),"id")){case(?val){val};case(_){{name ="Not found"}}}).name);
          };
          case(_) {
            #Text("not a class");
          };
        };
      };
    };
  """

  testCase """
    class body identifier
    ---
    shared (deployer) actor class test_runner(dfx_ledger: Principal, dfx_ledger2: Principal) = this

      let debug_channel =
        throws = true
    ---
    shared (deployer) actor class test_runner(dfx_ledger: Principal, dfx_ledger2: Principal) = this {

      let debug_channel = {
        throws = true;
      };
    };
  """

  testCase """
    switch shouldn't require parens
    ---
    module
      public func getNFTOwner(metadata: CandyTypes.CandyValue) : Result.Result<Types.Account, Types.OrigynError>
        let val = take Properties.getClassProperty(metadata, Types.metadata.owner), return #err(Types.errors(#owner_not_found, "getNFTOwner - cannot find owner id in metadata", null))

        return #ok(
          switch val.value {
            case(#Principal(val)){#principal(val)}
            case(#Text(val)){#account_id(val)}
            case(#Class(val)){#extensible(#Class(val))}
            case(#Array(ary))
              switch ary {
                case(#frozen(items))
                  if(items.size() > 0)
                    #account(
                      {
                          owner = switch items[0] {
                            case(#Principal(val)){val }
                            case(_)
                              return #err(Types.errors(#improper_interface, "getNFTOwner -  improper interface, not a principal at 0 ", null))
                          }

                          sub_account = if(items.size() > 1)
                              switch items[1] {
                                case(#Blob(val)){?val  }
                                case(_)
                                  return #err(Types.errors(#improper_interface, "getNFTOwner -  improper interface, blob at 1 ", null))
                              }

                            else
                              null
                      })
                  else
                    return #err(Types.errors(#improper_interface, "ledger_interface -  improper interface, not enough items " # debug_show(ary), null))



                case(_){return #err(Types.errors(#improper_interface, "ledger_interface - send payment - improper interface, not frozen " # debug_show(ary), null))  }
              }
            case(_){return #err(Types.errors(#improper_interface, "ledger_interface - send payment - improper interface, not an array " , null))  }
          }

        )
    ---
    module {
      public func getNFTOwner(metadata: CandyTypes.CandyValue) : Result.Result<Types.Account, Types.OrigynError> {
        let val = switch(Properties.getClassProperty(metadata, Types.metadata.owner)){case(null){return #err(Types.errors(#owner_not_found, "getNFTOwner - cannot find owner id in metadata", null))};case(?val){val}};

        return #ok(
          switch(val.value) {
            case(#Principal(val)){#principal(val)};
            case(#Text(val)){#account_id(val)};
            case(#Class(val)){#extensible(#Class(val))};
            case(#Array(ary)) {
              switch(ary) {
                case(#frozen(items)) {
                  if(items.size() > 0) {
                    #account(
                      {
                          owner = switch(items[0]) {
                            case(#Principal(val)){val };
                            case(_) {
                              return #err(Types.errors(#improper_interface, "getNFTOwner -  improper interface, not a principal at 0 ", null));
                          };
                          };

                          sub_account = if(items.size() > 1) {
                              switch(items[1]) {
                                case(#Blob(val)){?val  };
                                case(_) {
                                  return #err(Types.errors(#improper_interface, "getNFTOwner -  improper interface, blob at 1 ", null));
                              };
                              };
                          }

                            else {
                              null;
                          };
                      });
                  }
                  else {
                    return #err(Types.errors(#improper_interface, "ledger_interface -  improper interface, not enough items " # debug_show(ary), null));
                  };
              };



                case(_){return #err(Types.errors(#improper_interface, "ledger_interface - send payment - improper interface, not frozen " # debug_show(ary), null))  };
              };
        };
            case(_){return #err(Types.errors(#improper_interface, "ledger_interface - send payment - improper interface, not an array " , null))  };
          }

        );
      };
    };
  """


  testCase """
    nested indented expression after variant gets parens
    ---
    module
      public func test(r: t): z.y

        return #a
          #b
            c
    ---
    module {
      public func test(r: t): z.y {

        return #a(
          #b(
            c));
      };
    };
  """
