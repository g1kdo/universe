import 'package:flutter/material.dart';

class DetailInfoSection extends StatelessWidget {
  final String accommodation;
  final String floor;
  final String type;

  const DetailInfoSection({
    super.key,
    required this.accommodation,
    required this.floor,
    required this.type,
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