import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/api_client.dart';
import '../home/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  XFile? photo;
  bool loading = false;

  Future<void> pickPhoto() async {
    final selected = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
    if (selected != null) setState(() => photo = selected);
  }

  Future<void> submit() async {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A foto do piloto e obrigatoria.')));
      return;
    }

    setState(() => loading = true);
    try {
      final api = ApiScope.of(context);
      final result = await api.register(
        name: name.text,
        email: email.text,
        phone: phone.text,
        password: password.text,
        photoPath: photo!.path,
      );
      api.setToken(result.data['accessToken'] as String);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nao foi possivel concluir o cadastro.')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de piloto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          OutlinedButton.icon(
            onPressed: pickPhoto,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(photo == null ? 'Adicionar foto obrigatoria' : 'Foto selecionada'),
          ),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
          const SizedBox(height: 12),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail')),
          const SizedBox(height: 12),
          TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
          const SizedBox(height: 22),
          ElevatedButton(onPressed: loading ? null : submit, child: Text(loading ? 'Cadastrando...' : 'Entrar na liga')),
        ],
      ),
    );
  }
}
