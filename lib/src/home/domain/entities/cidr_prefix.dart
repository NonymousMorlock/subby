import 'package:equatable/equatable.dart';

class CidrPrefix extends Equatable {
  factory CidrPrefix(int value) {
    if (value < 0 || value > 32) {
      throw ArgumentError.value(
        value,
        'An IPv4 CIDR prefix must be between 0 and 32.',
      );
    }
    return CidrPrefix._(value);
  }

  const CidrPrefix._(this.value);

  final int value;

  String get presentation => '/$value';

  @override
  List<Object?> get props => [value];
}
