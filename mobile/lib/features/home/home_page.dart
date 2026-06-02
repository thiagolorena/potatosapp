import 'package:flutter/material.dart';

import '../admin/admin_page.dart';
import '../calendar/category_calendar_page.dart';
import '../standings/category_standings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Box Potatos'),
        actions: [
          IconButton(
            tooltip: 'Administrativo',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPage())),
            icon: const Icon(Icons.admin_panel_settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Escolha sua proxima parada', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          _HomeAction(
            icon: Icons.event_available_outlined,
            title: 'Calendario',
            subtitle: 'Veja as etapas por categoria.',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoryCalendarPage())),
          ),
          _HomeAction(
            icon: Icons.leaderboard_outlined,
            title: 'Classificacao',
            subtitle: 'Acompanhe a tabela do campeonato.',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoryStandingsPage())),
          ),
        ],
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        minVerticalPadding: 18,
        leading: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
