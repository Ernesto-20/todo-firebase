import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/models/todo.dart';

class ToDoService {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Stream<List<ToDo>> fetch() async* {
    await Future.delayed(const Duration(seconds: 2));

    yield* db.collection('todo').snapshots().map((querySnapshot) {
      Map<String, StateToDo> toEnumState = {
        'created': StateToDo.created,
        'processing': StateToDo.processing,
        'finished': StateToDo.finished,
      };

      Map<String, TypeToDo> toEnumType = {
        'front': TypeToDo.front,
        'back': TypeToDo.back,
      };

      return querySnapshot.docs.map((doc) {
        return ToDo(
          id: doc.id,
          description: doc.data()['description'] ??
              '', // Accede al campo 'title' del documento
          time: doc.data()['time'] ?? '',
          date: doc.data()['date'] ?? '',
          manager: doc.data()['manager'] ?? '',
          state: toEnumState[doc.data()['state']] ?? StateToDo.created,
          isComplete: bool.fromEnvironment(doc.data()['isCompete'] ?? 'false'),
          type: toEnumType[doc.data()['type']] ?? TypeToDo.front,
        );
      }).toList()
        ..sort((ToDo a, ToDo b) {
          return '${b.date}${b.time}'.compareTo('${a.date}${a.time}');
        });
    });
  }

  static Future<bool> post(ToDo todo) async {
    bool added = false;
    await db.collection('todo').add({
      'description': todo.description,
      'time': todo.time,
      'date': todo.date,
      'manager': todo.manager,
      'isComplete': todo.isComplete,
      'state': todo.state.toString().split('.').last,
      'type': todo.type.toString().split('.').last,
    }).then((value) {
      added = true;
    }).onError((error, stackTrace) {
      added = false;
    });

    return added;
  }

  static Future<void> update(ToDo todo) async {
    return db
        .collection('todo')
        .doc(todo.id)
        .update({
          'state': todo.state.toString().split('.').last,
          'description': todo.description.toString(),
        })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  static Future<void> delete(ToDo todo) async {
    return db
        .collection('todo')
        .doc(todo.id)
        .delete()
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
