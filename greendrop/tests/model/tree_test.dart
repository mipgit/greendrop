import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/level.dart';
import 'package:greendrop/model/tree.dart';

void main() {
  group('Tree', () {
    final levels = [
      Level(levelNumber: 0, requiredDroplets: 0, levelPicture: 'level0.png'),
      Level(levelNumber: 1, requiredDroplets: 10, levelPicture: 'level1.png'),
      Level(levelNumber: 2, requiredDroplets: 25, levelPicture: 'level2.png'),
    ];

    test('initial values are set correctly', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
      );
      expect(tree.id, 'tree001');
      expect(tree.name, 'Test Tree');
      expect(tree.species, 'Test Species');
      expect(tree.description, 'A test tree.');
      expect(tree.levels, levels);
      expect(tree.price, 50);
      expect(tree.curLevel, 0);
      expect(tree.dropletsUsed, 0);
    });

    test('waterTree increments dropletsUsed', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
      );
      tree.waterTree();
      expect(tree.dropletsUsed, 1);
    });

    test('waterTree levels up the tree', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
        dropletsUsed: 9,
      );
      tree.waterTree();
      expect(tree.curLevel, 1);
      expect(tree.dropletsUsed, 10);
    });

    test('waterTree does not level up if not enough droplets', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
        dropletsUsed: 5,
      );
      tree.waterTree();
      expect(tree.curLevel, 0);
      expect(tree.dropletsUsed, 6);
    });

    test('getCurrentLevel returns the current level', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
        curLevel: 1,
      );
      expect(tree.getCurrentLevel(), levels[1]);
    });

    test('getCurrentLevel returns null if current level is out of bounds', () {
      final tree = Tree(
        id: 'tree001',
        name: 'Test Tree',
        species: 'Test Species',
        description: 'A test tree.',
        levels: levels,
        price: 50,
        curLevel: 3,
      );
      expect(tree.getCurrentLevel(), isNull);
    });
  });
}