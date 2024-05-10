import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/models/todo.dart';

class ToDoService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<List<ToDo>> fetch() async* {
    await Future.delayed(const Duration(seconds: 2));

    yield* db.collection('todo').snapshots().map((querySnapshot) {
      Map<String, StateToDo> toEnumState = {
        'news': StateToDo.news,
        'processing': StateToDo.processing,
        'finished': StateToDo.finished,
      };

      Map<String, TypeToDo> toEnumType = {
        'front': TypeToDo.front,
        'back': TypeToDo.back,
      };

      return querySnapshot.docs.map((doc) {
        return ToDo(
          description: doc.data()['description'] ??
              '', // Accede al campo 'title' del documento
          time: doc.data()['time'] ?? '',
          date: doc.data()['date'] ?? '',
          manager: doc.data()['manager'] ?? '',
          state: toEnumState[doc.data()['state']] ?? StateToDo.news,
          isComplete: bool.fromEnvironment(doc.data()['isCompete'] ?? 'false'),
          type: toEnumType[doc.data()['type']] ?? TypeToDo.front,
        );
      }).toList();
    });
  }

  Future<bool> post(ToDo todo) async {
    bool added = false;
    print('h1');
    await db.collection('todo').add({
      'description': todo.description,
      'time': todo.time,
      'date': todo.date,
      'manager': todo.manager,
      'isComplete': todo.isComplete,
      'state': '${todo.state}',
      'type' : '${todo.type}',
    }).then((value) {
      print('h2');
      added = true;
    }).onError((error, stackTrace) {
      print('h3');
      print(error);
      added = false;
    });
    print('h4');

    return added;
  }
}
