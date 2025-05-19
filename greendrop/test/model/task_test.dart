import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/task.dart';

void main() {
  group('Task', () {
    final now = DateTime.now();

    test('initial values are set correctly', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
      );
      expect(task.id, 'task001');
      expect(task.description, 'Water the plants');
      expect(task.dropletReward, 10);
      expect(task.isCompleted, false);
      expect(task.isPersonalized, false);
      expect(task.dueDate, isNull);
      expect(task.creationDate, now);
    });

    test('dueDate can be set', () {
      final dueDate = now.add(const Duration(days: 1));
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
        dueDate: dueDate,
      );
      expect(task.dueDate, dueDate);
    });

    test('isCompleted can be initialized as true', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
        isCompleted: true,
      );
      expect(task.isCompleted, true);
    });

    test('isPersonalized can be initialized as true', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
        isPersonalized: true,
      );
      expect(task.isPersonalized, true);
    });

    test('completeTask sets isCompleted to true', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
      );
      task.completeTask();
      expect(task.isCompleted, true);
    });

    test('unCompleteTask sets isCompleted to false', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 10,
        creationDate: now,
        isCompleted: true,
      );
      task.unCompleteTask();
      expect(task.isCompleted, false);
    });

    test('getReward returns the dropletReward', () {
      final task = Task(
        id: 'task001',
        description: 'Water the plants',
        dropletReward: 15,
        creationDate: now,
      );
      expect(task.getReward(), 15);
    });
  });
}