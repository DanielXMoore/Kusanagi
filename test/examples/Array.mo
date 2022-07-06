module {
  // Generates a new UUID.
  public func new() : UUID.UUID {
    let x = [
      Binary.BigEndian.fromNat32(low),
      Binary.BigEndian.fromNat16(mid),
      Binary.BigEndian.fromNat16(high),
      Binary.BigEndian.fromNat16(clock),
      node,
    ];
  };
}
