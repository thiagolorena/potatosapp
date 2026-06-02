import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';

class CategoryStandingsPage extends StatefulWidget {
  const CategoryStandingsPage({super.key});

  @override
  State<CategoryStandingsPage> createState() => _CategoryStandingsPageState();
}

class _CategoryStandingsPageState extends State<CategoryStandingsPage> {
  int? selectedCategory;
  List<dynamic> categories = [];
  List<dynamic> standings = [];

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
    final result = await ApiScope.of(context).standings(id);
    setState(() {
      selectedCategory = id;
      standings = result.data as List<dynamic>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classificacao')),
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
          for (final row in standings)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${row['position']}')),
                title: Text(row['user']['name'] as String),
                subtitle: Text('Vitorias ${row['wins']} | Poles ${row['poles']} | Corridas ${row['races']}'),
                trailing: Text('${row['points']} pts', style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
        ],
      ),
    );
  }
}
