class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.ownedTrees,
    required this.dailyTasks,
    this.droplets = 0
  });


  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  List<Map<String, dynamic>> ownedTrees;
  List<String> dailyTasks;
  int droplets;


  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

}