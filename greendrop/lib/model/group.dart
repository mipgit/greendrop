class Group {
  final String id;
  final String name;
  final String creatorId;
  final DateTime creationDate;
  List<String> memberIds;

  Group({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.creationDate,
    this.memberIds = const [],
  });

  void addMember(String userId) {
    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
    }
  }

  void removeMember(String userId) {
    memberIds.remove(userId);
  }
}