import 'package:flutter/material.dart';

import '../../core/navigation/app_route_observer.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';

class CategoryStandingsPage extends StatefulWidget {
  const CategoryStandingsPage({super.key});

  @override
  State<CategoryStandingsPage> createState() => _CategoryStandingsPageState();
}

class _CategoryStandingsPageState extends State<CategoryStandingsPage>
    with RouteAware {
  int? selectedCategory;
  List<dynamic> categories = [];
  List<dynamic> standings = [];
  bool loadingCategories = true;
  bool loadingStandings = false;
  String? errorMessage;
  bool subscribedToRoute = false;
  bool loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!subscribedToRoute && route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
      subscribedToRoute = true;
    }
    if (!loadedOnce) {
      loadedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) loadCategories();
      });
    }
  }

  @override
  void didPopNext() {
    loadCategories();
  }

  @override
  void didPush() {
    if (loadedOnce) loadCategories();
  }

  @override
  void dispose() {
    if (subscribedToRoute) appRouteObserver.unsubscribe(this);
    super.dispose();
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
          standings = [];
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
        errorMessage = 'Nao foi possivel carregar a classificacao.';
      });
    }
  }

  Future<void> selectCategory(int id) async {
    setState(() {
      selectedCategory = id;
      loadingStandings = true;
      errorMessage = null;
    });

    try {
      final result = await ApiScope.of(context).standings(id);
      if (!mounted) return;
      setState(() {
        standings = result.data as List<dynamic>;
        loadingStandings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        standings = [];
        loadingStandings = false;
        errorMessage =
            'Nao foi possivel carregar a classificacao desta categoria.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classificacao')),
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
            if (loadingStandings)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (!loadingCategories &&
                categories.isNotEmpty &&
                selectedCategory != null &&
                standings.isEmpty)
              const _EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Nenhuma classificacao cadastrada.',
                subtitle:
                    'Quando o admin atualizar os pilotos, a tabela aparece aqui.',
              )
            else
              for (final row in standings) _StandingCard(row: row as Map),
          ],
        ),
      ),
    );
  }
}

class _StandingCard extends StatelessWidget {
  const _StandingCard({required this.row});

  final Map<dynamic, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final user = row['user'] as Map<dynamic, dynamic>? ?? {};
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${row['position']}')),
        title: Text(
          user['name'] as String? ?? 'Piloto',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              _Metric(label: 'Vitorias', value: row['wins']),
              _Metric(label: 'Poles', value: row['poles']),
              _Metric(label: 'Corridas', value: row['races']),
              _Metric(label: 'VR', value: row['fastestLaps']),
            ],
          ),
        ),
        trailing: Text(
          '${row['points']} pts',
          style: const TextStyle(
            color: PotatosColors.racingOrange,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: const TextStyle(color: PotatosColors.smoke, fontSize: 12),
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
