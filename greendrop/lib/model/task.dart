class Task {

  Task({
    required this.id,
    required this.description,
    required this.dropletReward,
    required this.creationDate,
    this.isCompleted = false,
    this.dueDate
  });


  final String id;
  final String description;
  final int dropletReward;
  bool isCompleted;
  DateTime? dueDate; 
  final DateTime creationDate;

   
  void completeTask() {
    isCompleted = true;
  }

  void unCompleteTask() {
    isCompleted = false;
  }

  int getReward() {
    return dropletReward;
  }

}


