// ui/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/services/firestore_service.dart';
import 'package:universe/models/lost_found_model.dart';
import 'package:universe/models/club_model.dart';
import 'package:universe/ui/components/cards/lost_found_card.dart';
import 'package:universe/ui/components/cards/club_card.dart';
import 'package:universe/ui/components/forms/lost_found_form.dart';
import 'package:universe/ui/components/forms/club_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // Firestore service
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data streams
  late final Stream<List<LostFoundItem>> _lostItemsStream;
  late final Stream<List<Club>> _clubsStream;

  // Loading states
  final Map<String, bool> _loadingStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize data streams
    _lostItemsStream = _firestoreService.getLostItems();
    _clubsStream = _firestoreService.getClubs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper methods for CRUD operations
  void _setLoading(String key, bool loading) {
    setState(() {
      _loadingStates[key] = loading;
    });
  }

  bool _isLoading(String key) => _loadingStates[key] ?? false;


  Future<void> _resolveLostFoundItem(String itemId) async {
    final notes = await _showResolveDialog();
    if (notes != null) {
      try {
        _setLoading('resolve_lost_found_$itemId', true);
        await _firestoreService.resolveLostFoundItem(itemId, notes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item marked as resolved!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        _setLoading('resolve_lost_found_$itemId', false);
      }
    }
  }

  Future<void> _deleteLostFoundItem(String itemId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      try {
        _setLoading('delete_lost_found_$itemId', true);
        await _firestoreService.deleteLostFoundItem(itemId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        _setLoading('delete_lost_found_$itemId', false);
      }
    }
  }

  Future<void> _joinClub(String clubId) async {
    try {
      _setLoading('join_club_$clubId', true);
      await _firestoreService.joinClub(clubId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the club!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      _setLoading('join_club_$clubId', false);
    }
  }

  Future<void> _leaveClub(String clubId) async {
    final confirmed = await _showLeaveConfirmation();
    if (confirmed == true) {
      try {
        _setLoading('leave_club_$clubId', true);
        await _firestoreService.leaveClub(clubId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the club!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        _setLoading('leave_club_$clubId', false);
      }
    }
  }


  Future<void> _deleteClub(String clubId) async {
    final confirmed = await _showDeleteClubConfirmation();
    if (confirmed == true) {
      try {
        _setLoading('delete_club_$clubId', true);
        await _firestoreService.deleteClub(clubId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Club deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        _setLoading('delete_club_$clubId', false);
      }
    }
  }

  // Dialog methods
  Future<String?> _showResolveDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Resolution Notes',
            hintText: 'How was this resolved?',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showLeaveConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Club'),
        content: const Text('Are you sure you want to leave this club?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteClubConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Club'),
        content: const Text('Are you sure you want to delete this club? This action cannot be undone and all members will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              // title: const Text(
              //   'Community',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 20,
              //   ),
              // ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your campus community',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'at your fingertips!',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Lost Items'),
                Tab(text: 'Clubs'),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLostFoundContent(),
                _buildClubsContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLostFoundContent() {
    return CustomScrollView(
      slivers: [
        // Header with Add button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lost Items',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_auth.currentUser != null)
                  ElevatedButton.icon(
                    onPressed: () => _showLostFoundForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Report Lost Item'),
                  ),
              ],
            ),
          ),
        ),
        
        // Lost Items List
        StreamBuilder<List<LostFoundItem>>(
          stream: _lostItemsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            
            final lostItems = snapshot.data ?? [];
            
            if (lostItems.isEmpty) {
              return SliverFillRemaining(
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No lost items reported yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = lostItems[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LostFoundCard(
                      item: item,
                      onTap: () => _showLostFoundDetails(item),
                      onEdit: () => _showLostFoundForm(item: item),
                      onDelete: () => _deleteLostFoundItem(item.id),
                      onResolve: () => _resolveLostFoundItem(item.id),
                    ),
                  );
                },
                childCount: lostItems.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClubsContent() {
    return CustomScrollView(
      slivers: [
        // Header with Add button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Clubs & Organizations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_auth.currentUser != null)
                  ElevatedButton.icon(
                    onPressed: () => _showClubForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Club'),
                  ),
              ],
            ),
          ),
        ),
        
        // Clubs Grid
        StreamBuilder<List<Club>>(
          stream: _clubsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return SliverFillRemaining(
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }
            
            final clubs = snapshot.data ?? [];
            
            if (clubs.isEmpty) {
              return SliverFillRemaining(
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No clubs available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final club = clubs[index];
                    return FutureBuilder<bool>(
                      future: _firestoreService.isUserMemberOfClub(club.id),
                      builder: (context, memberSnapshot) {
                        final isMember = memberSnapshot.data ?? false;
                        return ClubCard(
                          club: club,
                          isMember: isMember,
                          isLoading: _isLoading('join_club_${club.id}') || _isLoading('leave_club_${club.id}'),
                          onTap: () => _showClubDetails(club),
                          onJoin: () => _joinClub(club.id),
                          onLeave: () => _leaveClub(club.id),
                          onEdit: () => _showClubForm(club: club),
                          onDelete: () => _deleteClub(club.id),
                        );
                      },
                    );
                  },
                  childCount: clubs.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Navigation methods
  void _showLostFoundForm({LostFoundItem? item}) {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to report items')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LostFoundForm(
          key: const ValueKey('lost_found_form'),
          item: item,
          userId: user.uid,
          userName: user.displayName ?? 'Unknown User',
          userEmail: user.email,
          userPhone: user.phoneNumber,
          onSuccess: () {
            // Refresh the data or show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(item == null ? 'Lost item reported successfully!' : 'Lost item updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showClubForm({Club? club}) {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create clubs')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubForm(
          key: const ValueKey('club_form'),
          club: club,
          userId: user.uid,
          userName: user.displayName ?? 'Unknown User',
          userEmail: user.email,
          onSuccess: () {
            // Refresh the data or show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(club == null ? 'Club created successfully!' : 'Club updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLostFoundDetails(LostFoundItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image if available
              if (item.imageUrl != null) ...[
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text('Type: ${item.type.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Category: ${item.category.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Location: ${item.location}'),
              const SizedBox(height: 8),
              Text('Description: ${item.description}'),
              const SizedBox(height: 8),
              Text('Reported by: ${item.reporterName}'),
              const SizedBox(height: 8),
              Text('Date: ${item.reportedAt.toString().split(' ')[0]}'),
              if (item.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes: ${item.notes}'),
              ],
              if (item.isResolved) ...[
                const SizedBox(height: 8),
                const Text('Status: RESOLVED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClubDetails(Club club) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(club.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo if available
              if (club.logoUrl != null) ...[
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(club.logoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text('Category: ${club.category.toUpperCase()}'),
              const SizedBox(height: 8),
              Text('Description: ${club.description}'),
              const SizedBox(height: 8),
              Text('President: ${club.presidentName}'),
              const SizedBox(height: 8),
              Text('Members: ${club.memberCount}/${club.maxMembers}'),
              const SizedBox(height: 8),
              Text('Meeting Schedule: ${club.meetingSchedule}'),
              const SizedBox(height: 8),
              Text('Meeting Location: ${club.meetingLocation}'),
              if (club.website != null) ...[
                const SizedBox(height: 8),
                Text('Website: ${club.website}'),
              ],
              if (club.socialMedia != null) ...[
                const SizedBox(height: 8),
                Text('Social Media: ${club.socialMedia}'),
              ],
              if (club.contactInfo != null) ...[
                const SizedBox(height: 8),
                Text('Contact: ${club.contactInfo}'),
              ],
              if (club.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Tags: ${club.tags.join(', ')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}