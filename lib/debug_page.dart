import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DebugPage extends StatefulWidget {
  final Database database;

  const DebugPage({super.key, required this.database});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  String _log = '';

  Future<void> _printTableStructure() async {
    final data = await widget.database.query("sqlite_master");
    setState(() {
      _log = 'Table Structure: ${data.toString()}';
      print(_log);
    });
  }

  Future<void> _printTableContent() async {
    final data = await widget.database.query("todos");
    setState(() {
      _log = 'Table Content: ${data.toString()}';
      print(_log);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _printTableStructure,
            child: const Text('Print Table Structure'),
          ),
          ElevatedButton(
            onPressed: _printTableContent,
            child: const Text('Print Table Content'),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text('Log: $_log'),
            ),
          ),
        ],
      ),
    );
  }
}
