import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailInfoSection extends ConsumerWidget {
  final String accommodation;
  final String floor;
  final String type;
  final bool isAvailable;
  final List<String> equipment;
  final String? contactPerson;

  const DetailInfoSection({
    super.key,
    required this.accommodation,
    required this.floor,
    required this.type,
    required this.isAvailable,
    required this.equipment,
    this.contactPerson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, 'Accommodation:', accommodation),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Floor:', floor),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Type:', type),
        const SizedBox(height: 8),
        _buildStatusRow(context, 'Status:', isAvailable),
        if (equipment.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildEquipmentSection(context),
        ],
        if (contactPerson != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Contact Person:', contactPerson!),
        ],
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, bool isAvailable) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAvailable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha:0.3)),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}