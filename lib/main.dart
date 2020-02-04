import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/item.dart';

void main() => runApp(App());
class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget{
  var items = new List<Item>();
  HomePage() {
    items: [];
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add(){
    if(newTaskCtrl.text.isEmpty) return;
    setState((){
      widget.items.add(
        Item(
          title: newTaskCtrl.text,
          done: false
        ),
      );
      newTaskCtrl.text = "";
//      newTaskCtrl.clear();
      save();
    });
  }
  void remove(int index){
  setState(() {
    widget.items.removeAt(index);
    save();
  });
  }
  Future load() async {
      var prefs = await SharedPreferences.getInstance();
      var data = prefs.getString('data');

      if(data != null) {
        Iterable decoded = jsonDecode(data);
        List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();
        setState(() {
          widget.items = result;
        });
      }
  }
  _HomePageState(){
    load();
  }
  save()async{
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextFormField(
            controller: newTaskCtrl,
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              labelText: "Nova Tarefa",
              labelStyle: TextStyle(color: Colors.white)
            ),

          ),
//        leading: Text("Menu"),
//        title: Text("Meu App"),
//        actions: <Widget>[
//          Icon(Icons.clear_all)
//        ]
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctt, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              key: Key(item.title),
              value: item.done,
              onChanged: (value) {
                setState((){
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.deepOrange.withOpacity(0.7),
              child: Text("Remove"),
            ),
            onDismissed: (direction){
              remove(index);
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}