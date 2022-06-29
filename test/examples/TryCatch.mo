/** Trying out lots of constructions */

import Debug "mo:base/Debug";

module {
  public shared func ring() : async () {
    try {
      Debug.print("Ring!");
    } catch e {
      Debug.print("ehh");
    };

    try Debug.print("wat")
    catch e Debug.print "exx"
  };
}
