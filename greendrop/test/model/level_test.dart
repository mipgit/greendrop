import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/level.dart';

void main() {
  group('Level', () {
    test('initial values are set correctly', () {
      final level = Level(
        levelNumber: 1,
        requiredDroplets: 15,
        levelPicture: 'level1.png',
      );
      expect(level.levelNumber, 1);
      expect(level.requiredDroplets, 15);
      expect(level.levelPicture, 'level1.png');
    });
  });
}