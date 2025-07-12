// ui/screens/community_screen.dart
import 'package:flutter/material.dart';
import 'package:universe/ui/components/bars/search_bar_widget.dart';

// Import the new community-specific components
// import 'package:universe/ui/components/community_header.dart';
import 'package:universe/ui/components/sections/lost_found_section.dart';
import 'package:universe/ui/components/sections/club_organization_directory.dart';

class UniVerseUClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from top-left
    path.moveTo(0, size.height * 0.2);
    // Line to bottom-left
    path.lineTo(0, size.height * 0.8);
    // Arc to bottom-right
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.8);
    // Line to top-right
    path.lineTo(size.width, size.height * 0.2);
    // Line to create the inner cut-out for the 'U'
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.75);
    path.quadraticBezierTo(size.width / 2, size.height * 0.65, size.width * 0.2, size.height * 0.75);
    path.lineTo(size.width * 0.2, size.height * 0.2);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom Clipper for the 'V' shape of the UniVerse logo (now upside down)
class UniVerseVClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start at top-left
    path.moveTo(0, 0);
    // Line to top-right
    path.lineTo(size.width, 0);
    // Line to bottom-center (making it an upside-down V)
    path.lineTo(size.width / 2, size.height);
    // Close the path to form a triangle
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  late TabController _tabController; // Controller for segmented control
  late AnimationController _logoAnimationController;
  // Animation for the 'U' shape's position (slide from top-left)
  late Animation<Offset> _uSlideAnimation;
  // Animation for the 'V' shape's position (slide from top-right)
  late Animation<Offset> _vSlideAnimation;

  // Controller for the text and buttons fade-in animation
  late AnimationController _textButtonsAnimationController;
  // Animation for the opacity of the text and buttons
  late Animation<double> _textButtonsOpacityAnimation;

  // Add a boolean flag to indicate if animations are initialized
  bool _animationsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Duration for the UV shapes to fall
    );

    // Define the animation for the 'U' shape
    // It starts off-screen at the top-left and lands slightly to the left
    _uSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.8, -2.0), // Start from further top-left
      end: const Offset(-0.2, 0.0),    // End slightly to the left for balance
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack, // Provides a slight bounce effect at the end
    ));

    // Define the animation for the 'V' shape
    // It starts off-screen at the top-right and lands slightly to the right and down,
    // creating the "falling on" effect.
    _vSlideAnimation = Tween<Offset>(
      begin: const Offset(0.8, -2.0), // Start from further top-right
      end: const Offset(0.2, 0.1),    // End slightly to the right and down to overlap 'U'
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeOutBack, // Same curve for consistent landing
    ));

    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textButtonsAnimationController.forward(); // Start the fade-in
      }
    });

    // Start the logo animation
    _logoAnimationController.forward();

    // Ensure _animationsInitialized is set to true after the first frame
    // This guarantees that all 'late' variables are initialized before
    // the build method attempts to use them in subsequent renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _animationsInitialized = true;
        });
      }
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    _logoAnimationController.dispose();
    super.dispose();
  }

  // --- Placeholder Data for Community Screen ---
  final List<Map<String, String>> _lostItemsData = [
    {
      'title': 'Lost Keys',
      'description': 'Set of car keys with a blue lanyard, lost near the main library entrance.',
      'type': 'Lost',
      'date': 'July 10, 2025',
      'image': 'https://placehold.co/80x80/FFD700/000000?text=Keys',
    },
    {
      'title': 'Missing Textbook',
      'description': 'Calculus textbook, 5th edition, left in Lecture Hall A on Tuesday.',
      'type': 'Lost',
      'date': 'July 09, 2025',
      'image': 'https://placehold.co/80x80/FFA07A/000000?text=Book',
    },
    {
      'title': 'Lost Wallet (Brown)',
      'description': 'Brown leather wallet with student ID inside, lost around the canteen area.',
      'type': 'Lost',
      'date': 'July 08, 2025',
      'image': 'https://placehold.co/80x80/CD853F/FFFFFF?text=Wallet',
    },
  ];

  final List<Map<String, String>> _foundItemsData = [
    {
      'title': 'Found Headphones',
      'description': 'Pair of black wireless headphones found near the gym entrance.',
      'type': 'Found',
      'date': 'July 11, 2025',
      'image': 'https://placehold.co/80x80/98FB98/000000?text=Headphones',
    },
    {
      'title': 'Found Student ID Card',
      'description': 'Student ID card for "Jane Doe" found in the computer lab.',
      'type': 'Found',
      'date': 'July 09, 2025',
      'image': 'https://placehold.co/80x80/87CEFA/000000?text=ID',
    },
  ];

  final List<Map<String, String>> _clubsData = [
    {
      'name': 'Coding Ninjas',
      'description': 'A club for coding enthusiasts, offering workshops and hackathons.',
      'logo': 'https://placehold.co/60x60/8A2BE2/FFFFFF?text=CN',
    },
    {
      'name': 'Debate Society',
      'description': 'Hone your public speaking and argumentation skills.',
      'logo': 'https://placehold.co/60x60/4682B4/FFFFFF?text=DS',
    },
    {
      'name': 'Photography Club',
      'description': 'Capture moments and explore the art of photography.',
      'logo': 'https://placehold.co/60x60/DAA520/FFFFFF?text=PC',
    },
    {
      'name': 'Eco Warriors',
      'description': 'Promoting environmental awareness and sustainability on campus.',
      'logo': 'https://placehold.co/60x60/228B22/FFFFFF?text=EW',
    },
    {
      'name': 'Student Government Association',
      'description': 'Representing student interests and organizing campus events.',
      'logo': 'https://placehold.co/60x60/DC143C/FFFFFF?text=SGA',
    },
    {
      'name': 'Chess Club',
      'description': 'For chess enthusiasts of all skill levels.',
      'logo': 'https://placehold.co/60x60/7B68EE/FFFFFF?text=CC',
    },
    {
      'name': 'Drama Club',
      'description': 'Exploring the world of theatre and performance.',
      'logo': 'https://placehold.co/60x60/FF6347/FFFFFF?text=DC',
    },
    {
      'name': 'Robotics Team',
      'description': 'Designing and building robots for competitions.',
      'logo': 'https://placehold.co/60x60/5F9EA0/FFFFFF?text=RT',
    },
  ];

  void _handleLostFoundItemTap(Map<String, String> item) {
    print('Tapped on Lost/Found Item: ${item['title']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${item['title']}')),
    );
  }

  void _handleClubTap(Map<String, String> club) {
    print('Tapped on Club: ${club['name']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${club['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand, // Make stack fill the flexible space
                children: [
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: _animationsInitialized
                        ? Stack(
                      alignment: Alignment.center,
                      children: [
                        SlideTransition(
                          position: _uSlideAnimation,
                          child: ClipPath(
                            clipper: UniVerseUClipper(),
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _vSlideAnimation,
                          child: ClipPath(
                            clipper: UniVerseVClipper(),
                            child: Container(
                              width: 90,
                              height: 90,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                        : const SizedBox(), // Or a loading spinner if you prefer
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.5), // Increased opacity for better contrast
                  ),
                  // Positioned text content
                  const Positioned(
                    bottom: 110.0, // Adjusted to be above the search bar and tab bar
                    left: 16.0,
                    right: 16.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center, // Center the text horizontally
                      children: [
                        Text(
                          'Your campus community at your fingertips!',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100.0), // Height for search bar and tab bar
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SearchBarWidget(
                      onFilterPressed: () {
                        print('Community filter button pressed!');
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.black87,
                        tabs: const [
                          Tab(text: 'Lost & Found'),
                          Tab(text: 'Clubs'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lost Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._lostItemsData.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Image.network(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['description']}\nLost on: ${item['date']}'),
              isThreeLine: true,
              onTap: () => _handleLostFoundItemTap(item),
            ),
          )).toList(),
          const SizedBox(height: 20),
          Text(
            'Found Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._foundItemsData.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Image.network(item['image']!, width: 60, height: 60, fit: BoxFit.cover),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['description']}\nFound on: ${item['date']}'),
              isThreeLine: true,
              onTap: () => _handleLostFoundItemTap(item),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildClubsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.9, // Adjust as needed
        ),
        itemCount: _clubsData.length,
        itemBuilder: (context, index) {
          final club = _clubsData[index];
          return GestureDetector(
            onTap: () => _handleClubTap(club),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(club['logo']!),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      club['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        club['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}