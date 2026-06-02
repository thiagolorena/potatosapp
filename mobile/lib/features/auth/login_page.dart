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
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nao foi possivel entrar.')));
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
            const SizedBox(height: 28),
            const _BrandHeader(),
            const SizedBox(height: 36),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 14),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 22),
            ElevatedButton(onPressed: loading ? null : submit, child: Text(loading ? 'Entrando...' : 'Entrar no grid')),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage())),
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
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: PotatosColors.potatoYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.sports_motorsports, color: PotatosColors.asphalt, size: 42),
        ),
        const SizedBox(height: 18),
        Text('Potatos Racing', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Calendario, classificacao e perfil dos pilotos da liga.'),
      ],
    );
  }
}
