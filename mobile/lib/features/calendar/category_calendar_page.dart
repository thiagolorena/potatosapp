import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';

class CategoryCalendarPage extends StatefulWidget {
  const CategoryCalendarPage({super.key});

  @override
  State<CategoryCalendarPage> createState() => _CategoryCalendarPageState();
}

class _CategoryCalendarPageState extends State<CategoryCalendarPage> {
  int? selectedCategory;
  List<dynamic> categories = [];
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await ApiScope.of(context).categories();
    setState(() => categories = result.data as List<dynamic>);
  }

  Future<void> selectCategory(int id) async {
    final result = await ApiScope.of(context).calendar(id);
    setState(() {
      selectedCategory = id;
      events = result.data as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                ChoiceChip(
                  selected: selectedCategory == category['id'],
                  label: Text(category['name'] as String),
                  onSelected: (_) => selectCategory(category['id'] as int),
                ),
            ],
          ),
          const SizedBox(height: 20),
          for (final event in events)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${event['roundNumber']}')),
                title: Text(event['title'] as String),
                subtitle: Text('${event['trackName']} - ${event['startsAt']}'),
                trailing: Text(event['status'] as String),
              ),
            ),
        ],
      ),
    );
  }
}
