class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.bio,
    required this.ownedTrees,
    this.droplets = 0
  });


  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  String? bio;
  List<Map<String, dynamic>> ownedTrees;
  int droplets;


  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

}