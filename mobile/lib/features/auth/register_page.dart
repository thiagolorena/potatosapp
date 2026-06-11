import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';
import '../../core/widgets/potatos_logo.dart';
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

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
    if (selected != null) setState(() => photo = selected);
  }

  Future<void> submit() async {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A foto do piloto é obrigatória.')));
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
      final user = Map<String, dynamic>.from(result.data['user'] as Map);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage(user: user)),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      var message = 'Não foi possível concluir o cadastro.';
      if (error is DioException) {
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'].toString();
        }
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PotatosLogo(height: 28, width: 136)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          const _RegisterHeader(),
          const SizedBox(height: 24),
          _PhotoPickerCard(hasPhoto: photo != null, onTap: pickPhoto),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PotatosColors.pitWall,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PotatosColors.gridLine),
            ),
            child: Column(
              children: [
                TextField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!loading) submit();
                  },
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: loading ? null : submit,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_outlined),
                  label: Text(loading ? 'Criando conta...' : 'Criar conta'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crie sua conta de piloto',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PotatosColors.flagWhite,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Informe seus dados e escolha uma foto para identificação na liga.',
          style: TextStyle(
            color: PotatosColors.smoke,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _PhotoPickerCard extends StatelessWidget {
  const _PhotoPickerCard({required this.hasPhoto, required this.onTap});

  final bool hasPhoto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PotatosColors.pitWall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hasPhoto ? PotatosColors.racingOrange : PotatosColors.gridLine,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: hasPhoto
                      ? PotatosColors.racingOrange
                      : PotatosColors.gridLine,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasPhoto ? Icons.check : Icons.add_a_photo_outlined,
                  color: hasPhoto
                      ? PotatosColors.asphalt
                      : PotatosColors.flagWhite,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasPhoto ? 'Foto selecionada' : 'Escolher foto',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasPhoto
                          ? 'Tudo certo para criar sua conta.'
                          : 'Obrigatória para identificar seu perfil.',
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
