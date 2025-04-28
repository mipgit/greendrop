class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.ownedTrees,
    this.droplets = 0
  });


  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  List<Map<String, dynamic>> ownedTrees;
  int droplets;

User copyWith({
    String? id,
    String? username,
    String? email,
    List<Map<String, String>>? ownedTrees,
    int? droplets,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      ownedTrees: ownedTrees ?? this.ownedTrees,
      droplets: droplets ?? this.droplets,
    );
  }

  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

}