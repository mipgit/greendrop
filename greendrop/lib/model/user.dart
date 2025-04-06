class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    //required this.profilePicture,
    required this.ownedTrees,
    required this.ownedTasks,
    this.droplets = 0

  });


  final int id;
  final String username;
  final String email;
  //final String profilePicture;
  List<int> ownedTrees;
  List<int> ownedTasks;
  int droplets;


  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

}