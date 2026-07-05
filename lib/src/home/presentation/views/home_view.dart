import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:subby/core/constants/core_constants.dart';
import 'package:subby/src/home/domain/entities/cidr_prefix.dart';
import 'package:subby/src/home/domain/entities/ipv4_address.dart';
import 'package:subby/src/home/domain/entities/ipv4_network.dart';
import 'package:subby/src/home/presentation/layout/active_octet.dart';
import 'package:subby/src/home/presentation/layout/subnet_calculation_result.dart';
import 'package:subby/src/home/presentation/widgets/cidr_field.dart';
import 'package:subby/src/home/presentation/widgets/octet_field.dart';
import 'package:subby/src/home/presentation/widgets/results_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final List<TextEditingController> _addressControllers = List.generate(
    4,
    (_) => TextEditingController(text: CoreConstants.emptyCharacter),
  );

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  final cidrPrefixController = TextEditingController();
  final cidrPrefixFocusNode = FocusNode();

  SubnetCalculationResult? _result;

  int _getOctetValue(TextEditingController octetController) {
    return int.parse(
      octetController.text.trim().replaceAll(CoreConstants.emptyCharacter, ''),
    );
  }

  static const _cidrSubnet = {
    [1, 9, 17, 25]: 128,
    [2, 10, 18, 26]: 192,
    [3, 11, 19, 27]: 224,
    [4, 12, 20, 28]: 240,
    [5, 13, 21, 29]: 248,
    [6, 14, 22, 30]: 252,
    [7, 15, 23, 31]: 254,
    [8, 16, 24, 32]: 255,
  };

  bool _isCidrPrefixEmpty = true;

  int getHostCount(CidrPrefix cidrPrefix) {
    final hostBits = 32 - cidrPrefix.value;
    return math.max(0, math.pow(2, hostBits).toInt() - 2);
  }

  int _getSubnet(int prefix) {
    return _cidrSubnet.entries
        .firstWhere((entry) => entry.key.contains(prefix))
        .value;
  }

  Ipv4Address getSubnetMask(CidrPrefix cidrPrefix) {
    final prefix = cidrPrefix.value;
    List<int> octets;
    if (prefix == 0) {
      octets = [0, 0, 0, 0];
    } else if (prefix < 9) {
      octets = [_getSubnet(prefix), 0, 0, 0];
    } else if (prefix < 17) {
      octets = [255, _getSubnet(prefix), 0, 0];
    } else if (prefix < 25) {
      octets = [255, 255, _getSubnet(prefix), 0];
    } else {
      octets = [255, 255, 255, _getSubnet(prefix)];
    }
    return Ipv4Address(octets);
  }

  ActiveOctet? getActiveOctet(Ipv4Address subnetMask) {
    final index = subnetMask.octets.indexWhere((octet) => octet < 255);
    if (index == -1) return null;
    final octetPosition = OctetPosition.fromIndex(index);

    final blockSize = 256 - subnetMask.octets[index];

    return ActiveOctet(position: octetPosition, blockSize: blockSize);
  }

  Ipv4Address getNetworkAddress({
    required Ipv4Address address,
    required ActiveOctet? activeOctet,
  }) {
    if (activeOctet == null) return address;
    final activeOctetIPValue = address.octets[activeOctet.position.rawIndex];
    final blockSize = activeOctet.blockSize;

    for (var i = 0; i < 256; i += blockSize) {
      if (i + blockSize > activeOctetIPValue) {
        final networkAddress = List<int>.from(address.octets);
        networkAddress[activeOctet.position.rawIndex] = i;
        for (var i = activeOctet.position.rawIndex + 1; i < 4; i++) {
          networkAddress[i] = 0;
        }
        return Ipv4Address(networkAddress);
      }
    }
    throw Exception('Unable to calculate network address');
  }

  Ipv4Address getBroadcastAddress({
    required Ipv4Address networkAddress,
    required ActiveOctet? activeOctet,
  }) {
    if (activeOctet == null) return networkAddress;
    final broadcastAddress = List<int>.from(networkAddress.octets);
    final activeIndex = activeOctet.position.rawIndex;
    for (var i = activeIndex; i < 4; i++) {
      if (i == activeIndex) {
        broadcastAddress[i] =
            (networkAddress.octets[i] + activeOctet.blockSize) - 1;
      } else if (i > activeIndex) {
        broadcastAddress[i] = 255;
      }
    }
    return Ipv4Address(broadcastAddress);
  }

  SubnetCalculationResult findNetworkDetails(Ipv4Network network) {
    final hostCount = getHostCount(network.prefix!);
    final subnetMask = getSubnetMask(network.prefix!);
    final activeOctet = getActiveOctet(subnetMask);

    final networkAddress = getNetworkAddress(
      address: network.address,
      activeOctet: activeOctet,
    );

    final broadcastAddress = getBroadcastAddress(
      networkAddress: networkAddress,
      activeOctet: activeOctet,
    );
    log('Host Count: $hostCount');
    log('Subnet Mask: ${subnetMask.presentation}');
    log('Network Address: ${networkAddress.presentation}');
    log('Broadcast Address: ${broadcastAddress.presentation}');
    return SubnetCalculationResult(
      network: network,
      hostCount: hostCount,
      subnetMask: subnetMask,
      networkAddress: networkAddress,
      broadcastAddress: broadcastAddress,
    );
  }

  @override
  void initState() {
    super.initState();
    cidrPrefixController.addListener(_cidrPrefixListener);
  }

  void _cidrPrefixListener() {
    final isEmpty = cidrPrefixController.text.trim().isEmpty;
    if (isEmpty && !_isCidrPrefixEmpty) {
      setState(() {
        _isCidrPrefixEmpty = true;
      });
    } else if (!isEmpty && _isCidrPrefixEmpty) {
      setState(() {
        _isCidrPrefixEmpty = false;
      });
    }
  }

  @override
  void dispose() {
    for (var i = 0; i < _addressControllers.length; i++) {
      _focusNodes[i].dispose();
      _addressControllers[i].dispose();
    }
    cidrPrefixFocusNode.dispose();
    cidrPrefixController
      ..removeListener(_cidrPrefixListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colourScheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const .all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      mainAxisAlignment: _result == null
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 20,
                      children: [
                        Text(
                          'Subnet Calculator',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Enter an IPv4 address and CIDR prefix to view the '
                          'network values immediately below.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colourScheme.onSurfaceVariant,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: .center,
                                mainAxisSize: .min,
                                spacing: 10,
                                children: [
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const OutlineInputBorder()
                                          .borderRadius,
                                    ),
                                    child: ListView.separated(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: .zero,
                                      scrollDirection: .horizontal,
                                      shrinkWrap: true,
                                      itemCount: 4,
                                      separatorBuilder: (_, index) {
                                        return const Center(
                                          child: Text('.'),
                                        );
                                      },
                                      itemBuilder: (_, index) {
                                        final controller =
                                            _addressControllers[index];
                                        final focusNode = _focusNodes[index];
                                        final nextFocusNode = index == 3
                                            ? null
                                            : _focusNodes[index + 1];
                                        final previousFocusNode = index == 0
                                            ? null
                                            : _focusNodes[index - 1];

                                        return OctetField(
                                          key: ValueKey(index),
                                          controller: controller,
                                          focusNode: focusNode,
                                          nextFocusNode: nextFocusNode,
                                          previousFocusNode: previousFocusNode,
                                        );
                                      },
                                    ),
                                  ),
                                  const Text(
                                    '/',
                                    style: TextStyle(fontSize: 30),
                                  ),
                                  CidrField(
                                    controller: cidrPrefixController,
                                    focusNode: cidrPrefixFocusNode,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_isCidrPrefixEmpty)
                          Center(
                            child: Text(
                              'Leaving the CIDR prefix empty sets it to '
                              '0 automatically',
                              style: textTheme.labelSmall?.copyWith(
                                color: colourScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        FilledButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (_formKey.currentState!.validate()) {
                              final octets = _addressControllers
                                  .map(_getOctetValue)
                                  .toList(growable: false);
                              final address = Ipv4Address(octets);
                              final cidrPrefixValue =
                                  int.tryParse(
                                    cidrPrefixController.text.trim(),
                                  ) ??
                                  0;
                              final cidrPrefix = CidrPrefix(cidrPrefixValue);
                              final workingAddress = Ipv4Network(
                                address: address,
                                prefix: cidrPrefix,
                              );
                              setState(() {
                                _result = findNetworkDetails(workingAddress);
                              });
                            }
                          },
                          child: const Text('Submit'),
                        ),
                        if (_result case final result?)
                          ResultsCard(result: result),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
