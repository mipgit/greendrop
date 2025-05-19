import 'package:flutter_test/flutter_test.dart';
import 'package:greendrop/model/group.dart';

void main() {
  group('Group', () {
    final now = DateTime.now();

    test('initial values are set correctly', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
      );
      expect(group.id, 'group123');
      expect(group.name, 'Test Group');
      expect(group.creatorId, 'user456');
      expect(group.creationDate, now);
      expect(group.memberIds, isEmpty);
    });

    test('memberIds can be initialized with values', () {
      final initialMembers = ['user1', 'user2'];
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
        memberIds: initialMembers,
      );
      expect(group.memberIds, initialMembers);
    });

    test('addMember adds a member if not already present', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
      );
      group.addMember('user1');
      expect(group.memberIds, contains('user1'));
      expect(group.memberIds.length, 1);
    });

    test('addMember does not add a member if already present', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
        memberIds: ['user1'],
      );
      group.addMember('user1');
      expect(group.memberIds, contains('user1'));
      expect(group.memberIds.length, 1);
    });

    test('removeMember removes a member if present', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
        memberIds: ['user1', 'user2'],
      );
      group.removeMember('user1');
      expect(group.memberIds, isNot(contains('user1')));
      expect(group.memberIds, contains('user2'));
      expect(group.memberIds.length, 1);
    });

    test('removeMember does nothing if member is not present', () {
      final group = Group(
        id: 'group123',
        name: 'Test Group',
        creatorId: 'user456',
        creationDate: now,
        memberIds: ['user2'],
      );
      group.removeMember('user1');
      expect(group.memberIds, contains('user2'));
      expect(group.memberIds.length, 1);
    });
  });
}