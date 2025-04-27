import 'package:flutter/material.dart';
import 'package:greendrop/view-model/user_provider.dart';
import 'package:greendrop/view/garden/garden_view.dart';
import 'package:greendrop/view/home/home_view.dart';
// Import ProfilePage to access the static hero tag
import 'package:greendrop/view/profile/profile_view.dart';
import 'package:greendrop/view/tasks/tasks_view.dart';
import 'package:greendrop/view/groups/groups_view.dart';
import 'package:provider/provider.dart';
import 'package:greendrop/view/navbar/droplet_counter.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  int _selectedIndex = 1; // Default to Home view

  static final List<Widget> _widgetOptions = <Widget>[
    const GardenView(),
    const HomeView(),
    const TasksView(),
    const GroupsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // Get the color scheme for easier access
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            if (_selectedIndex != 1) {
               _onItemTapped(1);
            }
          },
          child: Text(
            'GreenDrop',
            // Use themed text style
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              // You might want to explicitly set color if needed
              // color: colorScheme.onSurface
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: Hero(
                    tag: ProfilePage.profileAvatarHeroTag,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: userProvider.user.profilePicture != null
                          ? NetworkImage(userProvider.user.profilePicture!)
                          : null,
                      // Use theme colors for icon/background
                      foregroundColor: colorScheme.onPrimaryContainer,
                      backgroundColor: colorScheme.primaryContainer,
                      child: userProvider.user.profilePicture == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const DropletCounter(),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
         padding: const EdgeInsets.only(top: 10.0),
         child: Center(child: _widgetOptions.elementAt(_selectedIndex)),
       ),
       // Alternative: Use IndexedStack to preserve state
       // body: IndexedStack(
       //   index: _selectedIndex,
       //   children: _widgetOptions,
       // ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjusted padding
        child: Material( // Use Material for elevation and shape
          elevation: 3.0,
          borderRadius: BorderRadius.circular(30.0),
          // Use theme color for the background of the Material widget
          color: colorScheme.surfaceVariant.withOpacity(0.8), // Example: Slightly transparent background
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
              height: 60,
              // Make NavigationBar itself transparent to see Material background
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              indicatorColor: colorScheme.primaryContainer,
              // --- FIX: Use WidgetStateProperty ---
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((Set<WidgetState> states) {
                 final Color labelColor = states.contains(WidgetState.selected)
                   ? colorScheme.onSurface // Color when selected
                   : colorScheme.onSurfaceVariant; // Color when not selected
                 return TextStyle(fontWeight: FontWeight.w500, color: labelColor, fontSize: 12);
               }),
              // Icon color is often handled well by the theme based on selection,
              // but you *can* theme it using NavigationBarTheme if needed.
              // We removed the incorrect 'iconTheme' parameter here.
              destinations: const [
                NavigationDestination(icon: Icon(Icons.local_florist_outlined), selectedIcon: Icon(Icons.local_florist), label: 'Garden'),
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.check_box_outline_blank), selectedIcon: Icon(Icons.check_box), label: 'Tasks'),
                NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group_rounded), label: 'Groups'),
              ],
            ),
          ),
        ),
    );
  }
}