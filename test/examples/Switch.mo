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
}
