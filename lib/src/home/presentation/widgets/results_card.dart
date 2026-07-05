import 'package:flutter/material.dart';
import 'package:subby/src/home/presentation/layout/subnet_calculation_result.dart';
import 'package:subby/src/home/presentation/widgets/result_tile.dart';

class ResultsCard extends StatelessWidget {
  const ResultsCard({required this.result, super.key});

  final SubnetCalculationResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colourScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colourScheme.primaryContainer.withValues(alpha: .9),
            colourScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colourScheme.outlineVariant),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colourScheme.shadow.withValues(alpha: .08),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              'Calculated Values',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              result.network.presentation,
              style: textTheme.bodyLarge?.copyWith(
                color: colourScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 500
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: ResultTile(
                        label: 'Host Count',
                        value: '${result.hostCount}',
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ResultTile(
                        label: 'Subnet Mask',
                        value: result.subnetMask.presentation,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ResultTile(
                        label: 'Network Address',
                        value: result.networkAddress.presentation,
                      ),
                    ),
                    SizedBox(
                      width: cardWidth,
                      child: ResultTile(
                        label: 'Broadcast Address',
                        value: result.broadcastAddress.presentation,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
