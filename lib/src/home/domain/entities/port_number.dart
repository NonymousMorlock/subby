import 'package:equatable/equatable.dart';

class PortNumber extends Equatable {
  factory PortNumber(int value) {
    if (value < lowerBound || value > upperBound) {
      throw ArgumentError.value(
        value,
        null,
        'Port number must be an integer between 0 and 65535.',
      );
    }
    return PortNumber._(value);
  }

  const PortNumber._(this.value);
  static const lowerBound = 0;
  static const upperBound = 65535;

  final int value;

  @override
  List<Object?> get props => [value];
}
