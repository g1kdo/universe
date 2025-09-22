import 'package:flutter/material.dart';
import 'package:universe/ui/components/details_screen_components/detail_description_section.dart';
import 'package:universe/ui/screens/virtual_reality_tour.dart';
import 'package:universe/models/lab_model.dart';

import '../components/details_screen_components/detail_image_header.dart';
import '../components/details_screen_components/detail_info_section.dart';

class DetailsScreen extends StatelessWidget {
  final Lab lab;

  const DetailsScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          DetailImageHeader(lab: lab),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Text(
                    lab.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailInfoSection(
                    accommodation: lab.accommodation,
                    floor: lab.floor,
                    type: lab.type,
                    isAvailable: lab.isAvailable,
                    equipment: lab.equipment,
                    contactPerson: lab.contactPerson,
                  ),
                  const SizedBox(height: 24),
                  DetailDescriptionSection(
                    description: lab.description,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VirtualRealityTourScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Watch on VR',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}