import 'package:flutter/material.dart';

class DetailInfoSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Accommodation:', accommodation),
        const SizedBox(height: 8),
        _buildInfoRow('Floor:', floor),
        const SizedBox(height: 8),
        _buildInfoRow('Type:', type),
        const SizedBox(height: 8),
        _buildStatusRow('Status:', isAvailable),
        if (equipment.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildEquipmentSection(),
        ],
        if (contactPerson != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow('Contact Person:', contactPerson!),
        ],
      ],
    );
  }

  Widget _buildStatusRow(String label, bool isAvailable) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isAvailable ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? 'Available' : 'Unavailable',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Equipment:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}