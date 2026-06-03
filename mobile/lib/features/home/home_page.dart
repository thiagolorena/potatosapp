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
          Text('Box Potatos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Acompanhe sua liga sem depender de planilhas.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          const _NextRaceStrip(),
          const SizedBox(height: 16),
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

class _NextRaceStrip extends StatelessWidget {
  const _NextRaceStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3037)),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department_outlined, color: Color(0xFFFF6210)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paddock ativo', style: TextStyle(fontWeight: FontWeight.w900)),
                Text('Calendario e ranking separados por categoria.', style: TextStyle(color: Colors.white70)),
              ],
            ),
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
