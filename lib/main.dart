import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:todo/models/todo.dart';
import 'package:todo/services/todoService.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late final ToDoService service;
  late final TabController tabController;
  late final Stream<List<ToDo>> streamController;

  @override
  void initState() {
    super.initState();
    service = ToDoService();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    streamController = service.fetch();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blue.shade900,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const MyAppBar(
            width: double.infinity,
            height: 150,
          ),
          body: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.elliptical(60, 30))),
            child: StreamBuilder<List<ToDo>>(
              stream: streamController,
              builder:
                  (BuildContext context, AsyncSnapshot<List<ToDo>> snapshot) {
                if (snapshot.hasError) {
                  return _buildError();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (snapshot.hasData) {
                  return _buildList(snapshot);
                }

                return const Placeholder();
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              TextEditingController descriptionController =
                  TextEditingController();
              showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(5)),
                        height: 300,
                        width: double.infinity,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text(
                                'New task',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              child: TextField(
                                controller: descriptionController,
                                maxLines: 4, // Para permitir múltiples líneas
                                keyboardType: TextInputType
                                    .multiline, // Para activar el teclado de múltiples líneas
                                decoration: const InputDecoration(
                                  hintText:
                                      'Write a new task description here...',
                                  hintStyle: TextStyle(fontSize: 15),
                                  border:
                                      OutlineInputBorder(), // Para agregar un borde alrededor del área de texto
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                    onPressed: () {},
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () async {
                                    DateTime now = DateTime.now();
                                    print('here 1');

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            backgroundColor: Colors.black,
                                            content: Container(
                                              alignment: Alignment.center,
                                              child: CircularProgressIndicator(
                                                color: Colors.blue.shade900,
                                              ),
                                            )));

                                    await service
                                        .post(ToDo(
                                            description:
                                                descriptionController.text,
                                            manager: 'unknow',
                                            state: StateToDo.news,
                                            time: '${now.hour}:${now.minute}',
                                            date:
                                                '${now.day}-${now.month}-${now.year}',
                                            isComplete: false,
                                            type: tabController.index == 0
                                                ? TypeToDo.front
                                                : TypeToDo.back))
                                        .then((bool value) {
                                      if (value) {
                                        Navigator.pop(context);
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(context)
                                              .clearSnackBars();
                                        });
                                      }
                                    });
                                  },
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.white54)),
                                  child: const Text('Save and close'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            },
            backgroundColor: Colors.blue.shade900,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ],
    );
  }

  Center _buildLoading() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Colors.blue.shade900,
        ),
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("Loading"),
        ),
      ],
    ));
  }

  Center _buildError() => Center(
          child: Text(
        'Something went wrong',
        style: TextStyle(color: Colors.red.shade900),
      ));

  Widget _buildList(AsyncSnapshot<List<ToDo>> snapshot) {
    List<ToDo> news = snapshot.data!
        .where((element) => element.state == StateToDo.news)
        .toList();
    List<ToDo> processing = snapshot.data!
        .where((element) => element.state == StateToDo.processing)
        .toList();
    List<ToDo> finish = snapshot.data!
        .where((element) => element.state == StateToDo.finished)
        .toList();

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildTabs(),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              ListView(
                children: [
                  news.isNotEmpty ? _labelToDo(label: 'New') : const SizedBox(),
                  ...news
                      .where((element) => element.type == TypeToDo.front)
                      .map((ToDo toDo) => ToDoItem(
                            toDo: toDo,
                          )),
                  processing.isNotEmpty
                      ? _labelToDo(label: 'Processing')
                      : const SizedBox(),
                  ...processing
                      .where((element) => element.type == TypeToDo.front)
                      .map((ToDo toDo) => ToDoItem(
                            toDo: toDo,
                          )),
                  finish.isNotEmpty
                      ? _labelToDo(label: 'Finished')
                      : const SizedBox(),
                ],
              ),
              ListView(
                children: [
                  news.isNotEmpty ? _labelToDo(label: 'New') : const SizedBox(),
                  ...news
                      .where((element) => element.type == TypeToDo.back)
                      .map((ToDo toDo) => ToDoItem(
                            toDo: toDo,
                          )),
                  processing.isNotEmpty
                      ? _labelToDo(label: 'Processing')
                      : const SizedBox(),
                  ...processing
                      .where((element) => element.type == TypeToDo.back)
                      .map((ToDo toDo) => ToDoItem(
                            toDo: toDo,
                          )),
                  finish.isNotEmpty
                      ? _labelToDo(label: 'Finished')
                      : const SizedBox(),
                ],
              ),
            ],
          ))
        ],
      ),
    );
  }

  Container _labelToDo({required String label}) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Text('State: $label'));
  }

  TabBar _buildTabs() {
    return TabBar(
      controller: tabController,
      labelColor: Colors.black,
      indicatorColor: Colors.black,
      labelStyle: const TextStyle(fontSize: 18),
      tabs: const [
        Tab(
          text: 'Frontend',
        ),
        Tab(
          text: 'Backend',
        ),
      ],
    );
  }
}

class ToDoItem extends StatelessWidget {
  const ToDoItem({
    super.key,
    required this.toDo,
  });

  final ToDo toDo;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: ListTile(
        onTap: () {},
        title: Text(toDo.description),
        subtitle: Text(toDo.manager),
        minLeadingWidth: 10,
        trailing: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 5, minHeight: 5),
          child: Checkbox(
            value: false,
            visualDensity: VisualDensity.compact,
            onChanged: (bool? value) {},
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => Size(width, height);
}

class _MyAppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.bottomCenter,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.task_rounded,
              color: Colors.white,
              size: 50,
            ),
            SizedBox(
              height: 10,
            ),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: 'ToDo ',
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'dev',
                style: TextStyle(fontSize: 35, color: Colors.white),
              )
            ])),
          ],
        ),
      ),
    );
  }
}
