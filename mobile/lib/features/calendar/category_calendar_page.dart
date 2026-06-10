import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';

class CategoryCalendarPage extends StatefulWidget {
  const CategoryCalendarPage({super.key});

  @override
  State<CategoryCalendarPage> createState() => _CategoryCalendarPageState();
}

class _CategoryCalendarPageState extends State<CategoryCalendarPage> {
  int? selectedCategory;
  List<dynamic> categories = [];
  List<dynamic> events = [];
  bool loadingCategories = true;
  bool loadingEvents = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() {
      loadingCategories = true;
      errorMessage = null;
    });

    try {
      final result = await ApiScope.of(context).categories();
      final loadedCategories = result.data as List<dynamic>;
      if (!mounted) return;
      setState(() {
        categories = loadedCategories;
        loadingCategories = false;
        if (!loadedCategories
            .any((category) => category['id'] == selectedCategory)) {
          selectedCategory = null;
          events = [];
        }
      });

      if (loadedCategories.isNotEmpty && selectedCategory == null) {
        await selectCategory(loadedCategories.first['id'] as int);
      } else if (selectedCategory != null) {
        await selectCategory(selectedCategory!);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loadingCategories = false;
        errorMessage = 'Nao foi possivel carregar o calendario.';
      });
    }
  }

  Future<void> selectCategory(int id) async {
    setState(() {
      selectedCategory = id;
      loadingEvents = true;
      errorMessage = null;
    });

    try {
      final result = await ApiScope.of(context).calendar(id);
      if (!mounted) return;
      setState(() {
        events = result.data as List<dynamic>;
        loadingEvents = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        events = [];
        loadingEvents = false;
        errorMessage = 'Nao foi possivel carregar as etapas desta categoria.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: RefreshIndicator(
        onRefresh: loadCategories,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (loadingCategories)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (categories.isEmpty)
              const _EmptyState(
                icon: Icons.category_outlined,
                title: 'Nenhuma categoria ativa encontrada.',
                subtitle:
                    'Assim que o admin ativar uma categoria, ela aparece aqui.',
              )
            else
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
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              _ErrorBanner(message: errorMessage!, onRetry: loadCategories),
            ],
            const SizedBox(height: 20),
            if (loadingEvents)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!loadingCategories &&
                categories.isNotEmpty &&
                selectedCategory != null &&
                events.isEmpty)
              const _EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'Nenhuma etapa cadastrada para esta categoria.',
                subtitle:
                    'Quando o calendario for publicado, as corridas aparecem aqui.',
              )
            else
              for (final event in events)
                Card(
                  child: ListTile(
                    leading:
                        CircleAvatar(child: Text('${event['roundNumber']}')),
                    title: Text(event['title'] as String),
                    subtitle: Text(
                        '${event['trackName']} - ${_formatDateTime(event['startsAt'] as String?)}'),
                    trailing: Text(event['status'] as String),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotatosColors.racingOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: PotatosColors.racingOrange.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined,
              color: PotatosColors.racingOrange),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          IconButton(
            tooltip: 'Tentar novamente',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 42, color: PotatosColors.racingOrange),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PotatosColors.smoke)),
        ],
      ),
    );
  }
}

String _formatDateTime(String? raw) {
  final value = DateTime.tryParse(raw ?? '');
  if (value == null) return raw ?? '';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
