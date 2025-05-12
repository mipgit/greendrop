class User {

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.bio,
    required this.ownedTrees,
    this.droplets = 0,
    this.role = 'user',
  });


  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  String? bio;
  List<Map<String, dynamic>> ownedTrees;
  int droplets;
  String role; 


User copyWith({
    String? id,
    String? username,
    String? email,
    List<Map<String, String>>? ownedTrees,
    int? droplets,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      ownedTrees: ownedTrees ?? this.ownedTrees,
      droplets: droplets ?? this.droplets,
      role: role ?? this.role,
    );
  }

  void addDroplets(int amount) {
    droplets += amount;
  }
 
  void takeDroplets(int amount) {
    droplets -= amount;
  }

}