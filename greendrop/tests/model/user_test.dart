import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/user.dart';

void main() {
  group('User', () {
    test('initial droplets should be set correctly', () {
      final user = User(id: '1', username: 'testuser', email: 'test@example.com', ownedTrees: [], droplets: 100);
      expect(user.droplets, 100);
    });

    test('addDroplets should increase the droplet count', () {
      final user = User(id: '1', username: 'testuser', email: 'test@example.com', ownedTrees: [], droplets: 50);
      user.addDroplets(25);
      expect(user.droplets, 75);
    });

    test('takeDroplets should decrease the droplet count', () {
      final user = User(id: '1', username: 'testuser', email: 'test@example.com', ownedTrees: [], droplets: 100);
      user.takeDroplets(30);
      expect(user.droplets, 70);
    });

    test('ownedTrees should be initialized as an empty list', () {
      final user = User(id: '1', username: 'testuser', email: 'test@example.com', ownedTrees: []);
      expect(user.ownedTrees, isEmpty);
    });

    test('ownedTrees can be initialized with values', () {
      final initialTrees = [{'treeId': 'oak123'}];
      final user = User(id: '1', username: 'testuser', email: 'test@example.com', ownedTrees: initialTrees);
      expect(user.ownedTrees, initialTrees);
    });
  });
}