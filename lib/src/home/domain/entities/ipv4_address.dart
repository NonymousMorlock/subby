import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class Ipv4Address extends Equatable {
  factory Ipv4Address(List<int> octets) {
    if (octets.length != 4) {
      throw ArgumentError.value(
        octets.join('.'),
        null,
        'An IPv4 address must contain exactly 4 octets.',
      );
    }
    for (final octet in octets) {
      if (octet < 0 || octet > 255) {
        throw ArgumentError.value(
          octet,
          null,
          'Each octet must be an integer between 0 and 255.',
        );
      }
    }
    return Ipv4Address._(Uint8List.fromList(octets).asUnmodifiableView());
  }

  const Ipv4Address._(this._octets);

  final Uint8List _octets;

  String get presentation => _octets.join('.');

  List<int> get octets => _octets;

  @override
  List<Object?> get props => _octets;
}
