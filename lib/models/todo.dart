
class ToDo{
  ToDo({required this.description, required this.manager, required this.state, required this.date, required this.time, required this.isComplete, required this.type});

  final String description;
  final String time;
  final String date;
  final String manager;
  final StateToDo state;
  final bool isComplete;
  final TypeToDo type;

}


enum StateToDo {news, processing, finished}
enum TypeToDo {front, back}