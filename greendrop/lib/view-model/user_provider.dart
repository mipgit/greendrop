import 'package:flutter/material.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';
import 'package:greendrop/model/user.dart';
import 'package:greendrop/view-model/tree_provider.dart';

class UserProvider with ChangeNotifier {
  List<Tree> userTrees = []; // user's trees
  List<TreeProvider> treeProviders = []; // list of TreeProviders
  User user;

  UserProvider()
    : user = User(
        id: 1,
        username: "johndoe",
        email: "johndoe@email.com",
        trees: [
          Tree(
            id: 1, name: 'Pine Tree', description: 'A tall pine.', species: 'Pine', price: 30, isBought: true,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png',),
              Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assets/tree.png',),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),

          Tree(
            id: 2, name: 'Palm Tree', description: 'A carefree palm.', species: 'Palm', price: 45, isBought: true,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png',),
              Level(levelNumber: 1, requiredDroplets: 20, levelPicture: 'assets/palms.png',),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),

          Tree(
            id: 3, name: 'Oak Tree', description: 'A sturdy oak.', species: 'Oak', price: 60, isBought: true,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png',),
              Level(levelNumber: 1, requiredDroplets: 30, levelPicture: 'assets/oak.png',),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
          
        ],

        tasks: [],
        droplets: 54,

      ) {
    userTrees = user.trees; 
    treeProviders = userTrees.map((tree) => TreeProvider(tree)).toList();
  }


  //adding methods to update user's info and TreeProviders as needed
  void updateTrees() {
    treeProviders = userTrees.map((tree) => TreeProvider(tree)).toList();
    notifyListeners();
  }

  void addDroplets(int amount) {
    user.addDroplets(amount); //this needs fixing but i dont want to change user class yet
    notifyListeners(); 
  }

  void takeDroplets(int amount) {
    user.takeDroplets(amount);
    notifyListeners(); 
  }

}