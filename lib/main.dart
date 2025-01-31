import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqflite_logger.dart';
import 'package:path/path.dart';
import 'todo_page.dart';
import 'debug_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ロガーの設定とデータベースの初期化
  var factoryWithLogs = SqfliteDatabaseFactoryLogger(databaseFactory,
      options:
          SqfliteLoggerOptions(type: SqfliteDatabaseFactoryLoggerType.all));

  // データベースの作成とテーブル定義
  var db = await factoryWithLogs.openDatabase(
    join(await getDatabasesPath(), 'todo_database.db'),
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY, title TEXT, done INTEGER)',
        );
      },
    ),
  );

  runApp(MyApp(database: db));
}

class MyApp extends StatelessWidget {
  final Database database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TODO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Database database;

  const MyHomePage({super.key, required this.database});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(Database database) => <Widget>[
        TodoPage(database: database),
        DebugPage(database: database),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO App'),
      ),
      body: _widgetOptions(widget.database)[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'TODO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report),
            label: 'Debug',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
