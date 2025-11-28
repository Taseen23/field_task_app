class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // pending, checked_in, completed
  final double latitude;
  final double longitude;
  final String? agentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.agentId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCheckedIn => status == 'checked_in';
  bool get isCompleted => status == 'completed';

  @override
  String toString() => 'Task(id: $id, title: $title, status: $status)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
