// lib/ui/components/cards/club_card.dart
import 'package:flutter/material.dart';
import 'package:universe/models/club_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isMember;
  final bool isLoading;

  const ClubCard({
    super.key,
    required this.club,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.onEdit,
    this.onDelete,
    this.isMember = false,
    this.isLoading = false,
  });

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Icons.school;
      case 'sports':
        return Icons.sports;
      case 'cultural':
        return Icons.palette;
      case 'social':
        return Icons.people;
      case 'professional':
        return Icons.business;
      case 'other':
      default:
        return Icons.group;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'sports':
        return Colors.green;
      case 'cultural':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      case 'professional':
        return Colors.teal;
      case 'other':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == club.presidentId;
    final isAdmin = club.adminIds.contains(currentUser?.uid);
    final categoryColor = _getCategoryColor(club.category);
    final memberCount = club.memberCount;
    final maxMembers = club.maxMembers;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with category and actions
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(club.category),
                          size: 12,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          club.category.toUpperCase(),
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Actions for owner/admin
                  if (isOwner || isAdmin) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.edit, size: 14, color: Colors.grey),
                            ),
                          ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.delete, size: 14, color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),

              // Club logo and name
              Row(
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: categoryColor.withValues(alpha: 0.1),
                    backgroundImage: club.logoUrl != null 
                        ? NetworkImage(club.logoUrl!) 
                        : null,
                    child: club.logoUrl == null
                        ? Icon(
                            _getCategoryIcon(club.category),
                            color: categoryColor,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  // Name and member count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '$memberCount/$maxMembers',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Expanded(
                child: Text(
                  club.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              // Meeting info (compact)
              if (club.meetingSchedule.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        club.meetingSchedule,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],

              // President info (compact)
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      club.presidentName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Join/Leave button
              if (!isOwner) ...[
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : (isMember ? onLeave : onJoin),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMember ? Colors.red : categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isMember ? 'Leave' : 'Join',
                            style: const TextStyle(fontSize: 12),
                          ),
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  height: 28,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'President',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
