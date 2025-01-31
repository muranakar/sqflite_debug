import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TodoPage extends StatefulWidget {
  final Database database;

  const TodoPage({super.key, required this.database});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  String _log = '';

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  Future<void> _refreshTodos() async {
    final data = await widget.database.query('todos');
    setState(() {
      _todos = data;
      _log = data.toString();
      print(_log);
    });
  }

  Future<void> _addTodo() async {
    final data = await widget.database.insert(
      'todos',
      {'title': _controller.text, 'done': 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _controller.clear();
    _refreshTodos();
    setState(() {
      _log = data.toString();
      print(_log);
    });
  }

  Future<void> _toggleTodoDone(int id, int done) async {
    final data = await widget.database.update(
      'todos',
      {'done': done == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    _refreshTodos();
    setState(() {
      _log = data.toString();
      print(_log);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'New TODO',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _addTodo,
          child: const Text('Add TODO'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return ListTile(
                title: Text(todo['title']),
                trailing: Checkbox(
                  value: todo['done'] == 1,
                  onChanged: (value) {
                    _toggleTodoDone(todo['id'], todo['done']);
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Log: $_log'),
        ),
      ],
    );
  }
}
