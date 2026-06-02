import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrativo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _AdminTile(icon: Icons.category_outlined, title: 'Categorias', subtitle: 'Cadastrar e editar categorias da liga.'),
          _AdminTile(icon: Icons.event_note_outlined, title: 'Calendario', subtitle: 'Cadastrar etapas, pistas, datas e status.'),
          _AdminTile(icon: Icons.emoji_events_outlined, title: 'Classificacao', subtitle: 'Atualizar pontos, posicoes e estatisticas.'),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
