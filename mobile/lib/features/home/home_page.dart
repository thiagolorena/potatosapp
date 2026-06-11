import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/potatos_theme.dart';
import '../../core/widgets/potatos_logo.dart';
import '../admin/admin_page.dart';
import '../calendar/category_calendar_page.dart';
import '../standings/category_standings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.user, super.key});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final userId = user['id'] as int?;
    final name = user['name'] as String? ?? 'Piloto';
    final role = (user['role'] as String? ?? 'PILOT').toUpperCase();
    final isAdmin = role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const PotatosLogo(height: 30),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: 'Administrativo',
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AdminPage())),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _PilotHeader(name: name, userId: userId),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            child: Column(
              children: [
                _HomeAction(
                  icon: Icons.event_available_outlined,
                  title: 'Calendário',
                  subtitle: 'Etapas e horários por categoria',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CategoryCalendarPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _HomeAction(
                  icon: Icons.leaderboard_outlined,
                  title: 'Classificação',
                  subtitle: 'Tabela, pontos e estatísticas',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CategoryStandingsPage()),
                  ),
                ),
                const SizedBox(height: 12),
                _HomeAction(
                  icon: Icons.open_in_new,
                  title: 'Site Potatos',
                  subtitle: 'Acesse o portal oficial da liga',
                  onTap: () => _openPotatosSite(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openPotatosSite(BuildContext context) async {
  final uri = Uri.parse('https://potatos.com.br/');
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir o site.')),
    );
  }
}

class _PilotHeader extends StatelessWidget {
  const _PilotHeader({required this.name, required this.userId});

  final String name;
  final int? userId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      decoration: const BoxDecoration(
        color: PotatosColors.asphalt,
        border: Border(
          bottom: BorderSide(color: PotatosColors.gridLine),
        ),
      ),
      child: Column(
        children: [
          _PilotAvatar(userId: userId),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  color: PotatosColors.flagWhite,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Piloto',
            style: TextStyle(
              color: PotatosColors.smoke,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PilotAvatar extends StatelessWidget {
  const _PilotAvatar({required this.userId});

  final int? userId;

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        userId == null ? null : '${AppConfig.apiBaseUrl}/users/$userId/photo';

    return Container(
      width: 108,
      height: 108,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PotatosColors.gridLine, width: 2),
        color: PotatosColors.pitWall,
      ),
      child: ClipOval(
        child: photoUrl == null
            ? const _AvatarFallback()
            : Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _AvatarFallback(),
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: PotatosColors.pitWall,
      child: Icon(
        Icons.sports_motorsports,
        color: PotatosColors.racingOrange,
        size: 46,
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PotatosColors.pitWall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: PotatosColors.gridLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: PotatosColors.racingOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: PotatosColors.racingOrange),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: PotatosColors.smoke,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PotatosColors.smoke),
            ],
          ),
        ),
      ),
    );
  }
}
