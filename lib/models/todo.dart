class ToDo {
  ToDo(
      {required this.id,
      required this.description,
      required this.manager,
      required this.state,
      required this.date,
      required this.time,
      required this.isComplete,
      required this.type});

  final String id;
  final String description;
  final String time;
  final String date;
  final String manager;
  final StateToDo state;
  final bool isComplete;
  final TypeToDo type;

  ToDo copyWith({
    final String? id,
    final String? description,
    final String? time,
    final String? date,
    final String? manager,
    final StateToDo? state,
    final bool? isComplete,
    final TypeToDo? type,
  }) {
    return ToDo(
        id: id ?? this.id,
        description: description ?? this.description,
        manager: manager ?? this.manager,
        state: state ?? this.state,
        date: date ?? this.date,
        time: time ?? this.time,
        isComplete: isComplete ?? this.isComplete,
        type: type ?? this.type);
  }
}

enum StateToDo { created, processing, finished }

enum TypeToDo { front, back }
