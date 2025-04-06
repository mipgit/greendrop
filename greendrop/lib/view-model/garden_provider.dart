import 'package:flutter/widgets.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';

class GardenProvider with ChangeNotifier{

  List<Tree> _allAvailableTrees = [];
  //bool _isLoading = true; //when we have database
  //String? _error; //when we have database

  List<Tree> get allAvailableTrees => _allAvailableTrees;
  //bool get isLoading => _isLoading;
  //String? get error => _error;


  GardenProvider() {
   _loadTreesFromFirebase();
  }




  Future<void> _loadTreesFromFirebase() async {

      //_isLoading = true;
      notifyListeners();

      try {
        // TO DO: firebase database connection

        // por agora, hardcoded
        _allAvailableTrees = [
          Tree(
            id: 1, name: 'Oli', description: 'A happy olive tree.', species: 'Olive Tree', price: 30, isBought: false,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'assets/olive-tree.png'),
              Level(levelNumber: 2, requiredDroplets: 30, levelPicture: 'assets/tree.png')
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
          Tree(
            id: 2, name: 'Palm', description: 'A carefree palm.', species: 'Palm Tree', price: 45, isBought: false,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 20, levelPicture: 'assets/palms.png'),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
          Tree(
            id: 3, name: 'Oak', description: 'A sturdy oak.', species: 'Oak Tree', price: 60, isBought: false,
            levels: [
              Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'assets/sprout.png'),
              Level(levelNumber: 1, requiredDroplets: 30, levelPicture: 'assets/oak.png'),
            ],
            dropletsUsed: 0, curLevel: 0,
          ),
        ];
        //_isLoading = false;
        notifyListeners();
      } catch (e) {
        //_isLoading = false;
        //_error = 'Failed to load tree data: $e';
        notifyListeners();
      }
  }

  // fot later : optional methods for filtering, sorting, searching
}