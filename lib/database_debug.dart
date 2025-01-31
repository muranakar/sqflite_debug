import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseDebugPage extends StatelessWidget {
  final Database database;

  const DatabaseDebugPage({super.key, required this.database});

  Future<List<Map<String, dynamic>>> _getTables() async {
    return await database
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
  }

  Future<List<Map<String, dynamic>>> _getTableContent(String tableName) async {
    return await database.query(tableName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTables(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tables = snapshot.data!;
          return ListView.builder(
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final tableName = tables[index]['name'];
              return ExpansionTile(
                title: Text(tableName),
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getTableContent(tableName),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rows = snapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: rows.isNotEmpty
                              ? rows.first.keys
                                  .map((key) => DataColumn(label: Text(key)))
                                  .toList()
                              : [],
                          rows: rows.map((row) {
                            return DataRow(
                              cells: row.values
                                  .map((value) =>
                                      DataCell(Text(value.toString())))
                                  .toList(),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
