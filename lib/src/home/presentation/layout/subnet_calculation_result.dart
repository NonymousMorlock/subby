import 'package:subby/src/home/domain/entities/ipv4_address.dart';
import 'package:subby/src/home/domain/entities/ipv4_network.dart';

class SubnetCalculationResult {
  const SubnetCalculationResult({
    required this.network,
    required this.hostCount,
    required this.subnetMask,
    required this.networkAddress,
    required this.broadcastAddress,
  });

  final Ipv4Network network;
  final int hostCount;
  final Ipv4Address subnetMask;
  final Ipv4Address networkAddress;
  final Ipv4Address broadcastAddress;
}
