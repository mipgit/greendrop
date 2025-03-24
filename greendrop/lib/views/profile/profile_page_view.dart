import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightGreen.shade900,
          ),
        ),
        backgroundColor: Colors.green.shade50,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.green.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 90,
              backgroundImage: AssetImage(
                'assets/sprout.png'), 
              backgroundColor: Colors.green.shade100,
              
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(title: Text('Name'), subtitle: Text('John Doe')),
                  ListTile(
                    title: Text('Email'),
                    subtitle: Text('john@gmail.com'),
                  ),
                  ListTile(
                    title: Text('Location'),
                    subtitle: Text('Porto, PT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
