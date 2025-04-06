import 'package:flutter/material.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/garden_provider.dart';
import 'package:greendrop/view-model/tree_provider.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  List<Tree> _userTrees = []; // user's trees
  List<TreeProvider> _treeProviders = []; // list of TreeProviders
  User user;

  List<Tree> get userTrees => _userTrees;
  List<TreeProvider> get treeProviders => _treeProviders;


  UserProvider(BuildContext context)
    : user = User(
        id: 1,
        username: "johndoe",
        email: "johndoe@email.com",
        ownedTrees: [1],
        tasks: [],
        droplets: 100,

      ) {
    _initializeUserTrees(context);
  }



  void _initializeUserTrees(BuildContext context) {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    _userTrees = user.ownedTrees.map((treeId) {
      return gardenProvider.allAvailableTrees.firstWhere(
        (tree) => tree.id == treeId,
        orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
      );
    }).toList();
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    notifyListeners();
  }


  // para Cuca/Narciso mudarem/usarem
  void buyTree(BuildContext context, int treeId) {
    final gardenProvider = Provider.of<GardenProvider>(context, listen: false);
    final treeToBuy = gardenProvider.allAvailableTrees.firstWhere(
      (tree) => tree.id == treeId,
      orElse: () => throw StateError('Tree with ID $treeId not found in catalog'),
    );


    if (user.droplets >= treeToBuy.price && !user.ownedTrees.contains(treeId)) {
      user.takeDroplets(treeToBuy.price);
      user.ownedTrees.add(treeId);
      _initializeUserTrees(context); // Re-fetch and update user's trees
      notifyListeners();
      print('${treeToBuy.name} bought successfully!');
    } else if (user.ownedTrees.contains(treeId)) {
      print('You already own ${treeToBuy.name}.');
    } else {
      print('Not enough droplets to buy ${treeToBuy.name}.');
    }
  }





  //adding methods to update user's info and TreeProviders as needed
  void updateTrees() {
    _treeProviders = _userTrees.map((tree) => TreeProvider(tree)).toList();
    notifyListeners();
  }

  void addDroplets(int amount) {
    user.droplets += amount; //this needs fixing but i dont want to change user class yet
    notifyListeners(); 
  }

  void takeDroplets(int amount) {
    user.droplets -= amount;
    notifyListeners(); 
  }

}