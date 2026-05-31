import 'package:equatable/equatable.dart';
import 'package:subby/src/home/domain/entities/cidr_prefix.dart';
import 'package:subby/src/home/domain/entities/ipv4_address.dart';

class Ipv4Network extends Equatable {
  const Ipv4Network({required this.address, this.prefix});

  /// Parse [text] as a dotted-decimal IPv4 address with an optional
  /// CIDR prefix.
  ///
  /// The [text] must contain four decimal octets separated by dots, with an
  /// optional `/prefix` suffix. Leading and trailing whitespace is ignored.
  ///
  /// Each octet must be in the range 0..255. If a CIDR prefix is present, it
  /// must be in the range 0..32.
  ///
  /// This parser validates the address and prefix ranges, but it does not
  /// require the address to be the base address of the CIDR block.
  ///
  /// If [text] does not contain a valid IPv4 address with an optional CIDR
  /// prefix, a [FormatException] or [ArgumentError] is thrown.
  ///
  /// Rather than throwing and immediately catching an exception, use
  /// [tryParse] to handle a potential parsing error.
  static Ipv4Network parse(String text) {
    return _parse(text: text, allowNull: false)!;
  }

  /// Parse [text] as a dotted-decimal IPv4 address with an optional
  /// CIDR prefix.
  ///
  /// Like [parse], except that this function returns `null` where a
  /// similar call to [parse] would throw a [FormatException] or
  /// [ArgumentError].
  ///
  /// Example:
  /// ```dart
  /// print(Ipv4Network.tryParse('192.168.1.0/24')?.presentation);
  /// // 192.168.1.0/24
  /// print(Ipv4Network.tryParse('10.0.0.1')?.presentation); // 10.0.0.1
  /// print(Ipv4Network.tryParse(' 172.16.0.0/16 ')?.presentation);
  /// // 172.16.0.0/16
  /// print(Ipv4Network.tryParse('256.0.0.1')); // null
  /// print(Ipv4Network.tryParse('10.0.0.0/33')); // null
  /// ```
  static Ipv4Network? tryParse(String text) {
    return _parse(text: text, allowNull: true);
  }

  static Ipv4Network? _parse({required String text, required bool allowNull}) {
    // Regex matches: 4 digit blocks separated by dots, and an optional trailing /digits block
    final regex = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})(?:/(\d{1,2}))?$',
    );
    final match = regex.firstMatch(text.trim());

    if (match == null) {
      if (allowNull) return null;
      throw FormatException(
        'Invalid IPv4 Network format matching string: $text',
      );
    }

    try {
      // Extract and parse the 4 core octets safely
      final octets = [
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      ];

      // Extract the optional CIDR prefix if it exists in the string
      final prefixString = match.group(5);
      final prefix = prefixString != null
          ? CidrPrefix(int.parse(prefixString))
          : null;

      return Ipv4Network(address: Ipv4Address(octets), prefix: prefix);
    } on Exception {
      if (allowNull) return null;
      rethrow;
    }
  }

  final Ipv4Address address;
  final CidrPrefix? prefix;

  String get presentation {
    return '${address.presentation}'
        '${prefix != null ? prefix!.presentation : ''}';
  }

  @override
  List<Object?> get props => [address, prefix];
}
