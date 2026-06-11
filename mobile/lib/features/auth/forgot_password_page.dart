import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/services/api_client.dart';
import '../../core/theme/potatos_theme.dart';
import '../../core/widgets/potatos_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();
  final code = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool loading = false;
  bool codeRequested = false;
  String? resetCode;

  @override
  void dispose() {
    email.dispose();
    code.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> requestCode() async {
    setState(() => loading = true);
    try {
      final result = await ApiScope.of(context).forgotPassword(email.text);
      final data = result.data;
      final generatedCode =
          data is Map<String, dynamic> ? data['resetCode']?.toString() : null;

      if (!mounted) return;
      setState(() {
        codeRequested = true;
        resetCode = generatedCode;
        if (generatedCode != null) code.text = generatedCode;
      });
      _showMessage('Código gerado. Agora cadastre uma nova senha.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error, 'Não foi possível gerar o código.'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resetPassword() async {
    if (password.text != confirmPassword.text) {
      _showMessage('As senhas precisam ser iguais.');
      return;
    }

    setState(() => loading = true);
    try {
      await ApiScope.of(context).resetPassword(
        email: email.text,
        code: code.text,
        password: password.text,
      );

      if (!mounted) return;
      _showMessage('Senha atualizada. Faça login com a nova senha.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage(_errorMessage(error, 'Não foi possível alterar a senha.'));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _errorMessage(Object error, String fallback) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map && responseData['message'] != null) {
        return responseData['message'].toString();
      }
    }
    return fallback;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PotatosLogo(height: 28, width: 136)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Text(
            'Recuperar senha',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PotatosColors.flagWhite,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Informe seu e-mail e crie uma nova senha para voltar ao app.',
            style: TextStyle(color: PotatosColors.smoke, height: 1.4),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: PotatosColors.pitWall,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PotatosColors.gridLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: email,
                  enabled: !codeRequested,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                if (!codeRequested) ...[
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: loading ? null : requestCode,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.password_outlined),
                    label: Text(
                      loading ? 'Gerando código...' : 'Gerar código',
                    ),
                  ),
                ] else ...[
                  if (resetCode != null) ...[
                    const SizedBox(height: 16),
                    _ResetCodeBanner(code: resetCode!),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: code,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nova senha',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!loading) resetPassword();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: loading ? null : resetPassword,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      loading ? 'Salvando...' : 'Salvar nova senha',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetCodeBanner extends StatelessWidget {
  const _ResetCodeBanner({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PotatosColors.racingOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PotatosColors.racingOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_outlined, color: PotatosColors.racingOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Código de recuperação: $code',
              style: const TextStyle(
                color: PotatosColors.flagWhite,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
