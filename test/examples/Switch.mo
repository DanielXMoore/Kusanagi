import Debug "mo:base/Debug";

module {
  public shared func ring() : async () {
    switch Debug {
      case Error {
        Debug.print("Yo")
      };
      case {print} {
        Debug.print("Hey")
      }
    };

    switch Debug {}
  };

  public func setClockSequence(seq : ?Nat16) {
    var s : Nat16 = switch (seq) {
        case (null) {
            let bs = switch (rand.read(2)) {
                case (#ok(bs))  bs;
                case (#eof(bs)) bs;
                case (#err(_)) {
                    assert(false); [];
                };
            };
            nat8to16(bs[0]) << 8 | nat8to16(bs[1]);
        };
        case (? s) { s; };
    };
  }
}
