module {
  public shared func ring () : async ()  {
    var x = 0;
    loop x := 1 + 2 while true;

    loop {
      x := 1 + 2
    } while false;

    loop {
      x := 1 + 2
    } while {
      x < 1
    };

    loop x := 3;

    loop {
      x:= 3
    }
  }
}
