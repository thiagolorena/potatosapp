import 'package:dio/dio.dart';
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
      final photoBytes = await photo!.readAsBytes();
      final result = await api.register(
        name: name.text,
        email: email.text,
        phone: phone.text,
        password: password.text,
        photoBytes: photoBytes,
        photoName: photo!.name,
      );
      api.setToken(result.data['accessToken'] as String);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    } catch (error) {
      if (!mounted) return;
      var message = 'Nao foi possivel concluir o cadastro.';
      if (error is DioException) {
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'].toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
          Text('Monte seu perfil de grid', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('A foto ajuda a identificar pilotos na classificacao e no paddock.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          _PhotoPickerCard(hasPhoto: photo != null, onTap: pickPhoto),
          const SizedBox(height: 18),
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

class _PhotoPickerCard extends StatelessWidget {
  const _PhotoPickerCard({required this.hasPhoto, required this.onTap});

  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 118,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hasPhoto ? const Color(0xFFFF6210) : const Color(0xFF2D3037)),
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: hasPhoto ? const Color(0xFFFF6210) : const Color(0xFF2D3037),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(hasPhoto ? Icons.check : Icons.add_a_photo_outlined, color: hasPhoto ? Colors.black : Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hasPhoto ? 'Foto selecionada' : 'Adicionar foto obrigatoria', style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Imagem compactada antes de salvar no MySQL.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
