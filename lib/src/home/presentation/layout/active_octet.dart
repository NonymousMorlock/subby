enum OctetPosition {
  first(0),
  second(1),
  third(2),
  fourth(3);

  const OctetPosition(this.rawIndex);

  final int rawIndex;

  static OctetPosition fromIndex(int index) {
    return values.firstWhere((position) => position.rawIndex == index);
  }
}

class ActiveOctet {
  const ActiveOctet({required this.position, required this.blockSize});

  final OctetPosition position;
  final int blockSize;
}
