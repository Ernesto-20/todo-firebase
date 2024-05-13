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
  late final TabController tabController;
  late final Stream<List<ToDo>> streamController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    streamController = ToDoService.fetch();
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
              // borderRadius:
              //     BorderRadius.vertical(top: Radius.elliptical(60, 20))
            ),
            child: StreamBuilder<List<ToDo>>(
              stream: streamController,
              builder:
                  (BuildContext context, AsyncSnapshot<List<ToDo>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading();
                }
                if (snapshot.hasData) {
                  return _buildList(snapshot);
                }

                return _buildError();
              },
            ),
          ),
          floatingActionButton: MyFloatingActionButton(
              tabController:
                  tabController), // This trailing comma makes auto-formatting nicer for build methods.
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
    List<ToDo> dataBack = snapshot.data!
        .where((ToDo element) => element.type == TypeToDo.back)
        .toList();
    List<ToDo> dataFront = snapshot.data!
        .where((ToDo element) => element.type == TypeToDo.front)
        .toList();

    // .where((element) => element.type == TypeToDo.back)
    // .map((ToDo toDo) => ToDoItem(
    //       toDo: toDo,
    //     )),

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          MyTabBar(tabController: tabController),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: TabBarView(
            controller: tabController,
            children: [
              ListView.separated(
                  itemBuilder: (_, index) => ToDoItem(
                        key: ValueKey(dataFront[index]),
                        toDo: dataFront[index],
                      ),
                  separatorBuilder: (_, index) => const Divider(),
                  itemCount: dataFront.length),
              ListView.separated(
                  itemBuilder: (_, index) => ToDoItem(
                        key: ValueKey(dataBack[index]),
                        toDo: dataBack[index],
                      ),
                  separatorBuilder: (_, index) => const Divider(),
                  itemCount: dataBack.length),
            ],
          ))
        ],
      ),
    );
  }
}

class MyTabBar extends StatefulWidget {
  const MyTabBar({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  State<MyTabBar> createState() => _MyTabBarState();
}

class _MyTabBarState extends State<MyTabBar>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController animationController;
  late Animation<Color?> animationFontEndTab;
  late Animation<Color?> animationBackEndTab;
  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    animationFontEndTab =
        ColorTween(begin: Colors.blue.shade900, end: Colors.white)
            .animate(animationController);
    animationBackEndTab =
        ColorTween(begin: Colors.white, end: Colors.blue.shade900)
            .animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.tabController,
      labelColor: Colors.blue.shade900,
      indicatorColor: Colors.blue.shade900,
      labelStyle: const TextStyle(fontSize: 18),
      onTap: (int index) {
        currentIndex = index;
        if (currentIndex == 1) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      },
      tabs: [
        Container(
          color: animationFontEndTab.value,
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            'Frontend',
            style: TextStyle(color: animationBackEndTab.value),
          ),
        ),
        Container(
          color: animationBackEndTab.value,
          width: double.infinity,
          height: 40,
          alignment: Alignment.center,
          child: Text(
            'Backend',
            style: TextStyle(color: animationFontEndTab.value),
          ),
        ),
      ],
    );
  }
}

class MyFloatingActionButton extends StatelessWidget {
  const MyFloatingActionButton({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        TextEditingController descriptionController = TextEditingController();
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
                            hintText: 'Write a new task description here...',
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
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              DateTime now = DateTime.now();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: Colors.black,
                                      content: Container(
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(
                                          color: Colors.blue.shade900,
                                        ),
                                      )));

                              await ToDoService.post(ToDo(
                                      id: '',
                                      description: descriptionController.text,
                                      manager: 'unknow',
                                      state: StateToDo.created,
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
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white54)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Icon(
        Icons.note_add_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class ToDoItem extends StatefulWidget {
  const ToDoItem({
    super.key,
    required this.toDo,
  });

  final ToDo toDo;

  @override
  State<ToDoItem> createState() => _ToDoItemState();
}

class _ToDoItemState extends State<ToDoItem> {
  bool select = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          select = !select;
        });
      },
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(child: NoteItem(toDo: widget.toDo)),
                _buildChangedState(context)
              ],
            ),
          ),
          if (select)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: const Color.fromARGB(220, 0, 0, 0),
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    ToDoService.delete(widget.toDo);
                  },
                  icon: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade900,
                    size: 40,
                  ),
                ),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildChangedState(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 40,
        padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10, left: 10),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: _buildAction(
                    state: StateToDo.created,
                    toDo: widget.toDo,
                    isSelected: widget.toDo.state == StateToDo.created)),
            Expanded(
                child: _buildAction(
                    state: StateToDo.processing,
                    toDo: widget.toDo,
                    isSelected: widget.toDo.state == StateToDo.processing)),
            Expanded(
                child: _buildAction(
                    state: StateToDo.finished,
                    toDo: widget.toDo,
                    isSelected: widget.toDo.state == StateToDo.finished)),
          ],
        ));
  }

  Widget _buildAction(
      {required StateToDo state,
      required bool isSelected,
      required ToDo toDo}) {
    return InkWell(
      onTap: () {
        // print("Selected: $state");
        ToDoService.update(toDo.copyWith(state: state));
      },
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isSelected ? Colors.blue.shade900 : Colors.transparent,
        ),
        child: Text(
          state.toString().split('.').last,
          style: isSelected
              ? const TextStyle(color: Colors.white, fontSize: 16)
              : null,
        ),
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  const NoteItem({super.key, required this.toDo});

  final ToDo toDo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          style: ListTileStyle.list,
          onTap: () {},
          title: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toDo.date,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      toDo.time,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Expanded(
                    child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Text(toDo.description)))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color? _getTagColor(StateToDo state) {
    switch (state) {
      case StateToDo.created:
        return Colors.yellow.shade600;
      case StateToDo.processing:
        return Colors.green.shade600;
      case StateToDo.finished:
        return Colors.blue.shade600;
    }
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
