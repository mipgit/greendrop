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
  State<NavigationView> createState() => NavigationViewState();
}

class NavigationViewState extends State<NavigationView> {
  int _selectedIndex = 1; //default to Home view

  static final List<Widget> _widgetOptions = <Widget>[
    const GardenView(),
    const HomeView(),
    const TasksView(),
    const GroupsView(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          onTap: () {
            if (_selectedIndex != 1) {
              onItemTapped(1);
            }
          },
          child: Text(
            'GreenDrop',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 30),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 227, 241, 234),
                borderRadius: BorderRadius.circular(23.0),
              ),
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
                        backgroundImage:
                            userProvider.user.profilePicture != null
                                ? NetworkImage(
                                  userProvider.user.profilePicture!,
                                )
                                : null,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        backgroundColor: colorScheme.primaryContainer,
                        child:
                            userProvider.user.profilePicture == null
                                ? const Icon(Icons.person, size: 20)
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const DropletCounter(),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(30.0),
          color: null,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 2.0,
              top: 13.0,
            ),
            child: NavigationBar(
              height: 50.0,
              backgroundColor: Colors.transparent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: onItemTapped,
              indicatorColor: Theme.of(context).colorScheme.primaryContainer,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.local_florist_rounded),
                  label: 'Garden',
                ),
                NavigationDestination(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.check_box),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.group_rounded),
                  label: 'Groups',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
