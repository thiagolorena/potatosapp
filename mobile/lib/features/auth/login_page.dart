import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';
import '../home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      final api = ApiScope.of(context);
      final result = await api.login(email.text, password.text);
      api.setToken(result.data['accessToken'] as String);
      final user = Map<String, dynamic>.from(result.data['user'] as Map);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel entrar.')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const _BrandHeader(),
            const SizedBox(height: 28),
            Text('Acesso do piloto',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 14),
            TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 22),
            ElevatedButton(
                onPressed: loading ? null : submit,
                child: Text(loading ? 'Entrando...' : 'Entrar no grid')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterPage())),
              child: const Text('Criar cadastro de piloto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PotatosColors.pitWall,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PotatosColors.gridLine),
              ),
              child: const Text('TEMPORADA 2026',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            ),
            const Spacer(),
            const Icon(Icons.flag_outlined, color: PotatosColors.racingOrange),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: PotatosColors.racingOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_motorsports,
              color: PotatosColors.asphalt, size: 42),
        ),
        const SizedBox(height: 18),
        Text('Potatos Racing',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text('Calendario, classificacao e perfil dos pilotos da liga.',
            style: TextStyle(color: PotatosColors.smoke)),
        const SizedBox(height: 22),
        const Row(
          children: [
            _MiniMetric(value: '2', label: 'modos'),
            SizedBox(width: 10),
            _MiniMetric(value: '100%', label: 'grid'),
            SizedBox(width: 10),
            _MiniMetric(value: 'live', label: 'liga'),
          ],
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PotatosColors.pitWall,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PotatosColors.gridLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: PotatosColors.racingOrange)),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: PotatosColors.smoke)),
          ],
        ),
      ),
    );
  }
}
