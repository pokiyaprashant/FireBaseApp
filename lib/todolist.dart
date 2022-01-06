import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _formKey = GlobalKey<FormState>();
  List<TaskModel> list = [];
  CollectionReference taskTable = FirebaseFirestore.instance.collection('task');

  String t = '';
  String q = '';

  String title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<TaskModel>>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                list = snapshot.data!;
                return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) => ListTile(
                          onTap: () {
                            updatedtask(list[index].title, list[index].id);
                          },
                          trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  taskTable.doc("${list[index].id}").delete();
                                });
                              },
                              icon: Icon(Icons.delete)),
                          title: Text(
                            "${list[index].title}",
                          ),
                        ));
              }
            }
            return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Form(
              key: _formKey,
              child: AlertDialog(
                actions: [
                  TextFormField(
                    decoration: InputDecoration(hintText: 'title'),
                    onChanged: (val) {
                      t = val;
                    },
                    // validator: (t) {
                    //   if (t == null) {
                    //     return 'please input';
                    //   }
                    // },
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          addData(context);
                        });
                        _formKey.currentState!.validate();
                      },
                      child: Text("Submit")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("cancel")),
                ],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<TaskModel>> getData() async {
    List<TaskModel> taskList = [];

    var tableData = await taskTable.get();

    if (tableData.docs.isNotEmpty) {
      tableData.docs.forEach((element) {
        var json = element.data() as Map;
        taskList.add(TaskModel(id: element.id, title: json["title"]));
      });
    }
    return taskList;
  }

  void addData(context) {
    CollectionReference taskTable =
        FirebaseFirestore.instance.collection('task');
    taskTable.doc().set({
      "title": t,
    });
    t = '';
    Navigator.pop(context);
    setState(() {
      getData();
    });
  }

  void updatedtask(String? title, String? id) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextFormField(
                  initialValue: title,
                  decoration: InputDecoration(hintText: 'title'),
                  onChanged: (p) {
                    title = p;
                  },
                ),
                TextButton(
                    onPressed: () {
                      setdata(y: title, z: id);
                    },
                    child: Text("sumbit")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("cancel"))
              ],
            ));
  }

  void setdata({String? y, String? z}) {
    CollectionReference taskTable =
        FirebaseFirestore.instance.collection('task');
    taskTable.doc(z).update({"title": y});
    Navigator.pop(context);
    setState(() {
      getData();
    });
  }
}

class TaskModel {
  final String? id;
  final String? title;

  TaskModel({this.id, this.title});
}
