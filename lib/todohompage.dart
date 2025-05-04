import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<String> _todos = [];
  final List<String> _filteredTodos = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _searchController.addListener(_filterTodos);
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      final todosList = List<String>.from(jsonDecode(todosString));
      setState(() {
        _todos.addAll(todosList);
        _filteredTodos.addAll(todosList);
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', jsonEncode(_todos));
  }

  void _addTodo() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        _todos.add(text);
        _controller.clear();
      });
      _saveTodos();
      _filterTodos();
    }
  }

  void _removeTodo(int index) {
    final todoToRemove = _filteredTodos[index];
    setState(() {
      _todos.remove(todoToRemove);
    });
    _saveTodos();
    _filterTodos();
  }

  void _filterTodos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTodos
          ..clear()
          ..addAll(_todos);
      } else {
        _filteredTodos
          ..clear()
          ..addAll(_todos.where((todo) => todo.toLowerCase().contains(query)));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Cari Tugas',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: const InputDecoration(
                      labelText: 'Tambahkan Tugas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Tambah'),
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredTodos.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada tugas ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredTodos.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(_filteredTodos[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeTodo(index),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
