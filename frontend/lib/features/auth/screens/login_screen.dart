import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post<Map<String, dynamic>>('/auth/login', data: {
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      });
      await ref.read(authNotifierProvider.notifier).saveToken(res.data!['token']);
      if (mounted) context.go('/');
    } catch (_) {
      setState(() => _error = 'Correo o contraseña incorrectos.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SedixColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: clayBox(radius: 32),
                    child: const FaIcon(
                      FontAwesomeIcons.piggyBank,
                      size: 48,
                      color: SedixColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Sedix',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: SedixColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ahorra con propósito.',
                    style: TextStyle(
                      fontSize: 14,
                      color: SedixColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _ClayField(
                    ctrl: _emailCtrl,
                    label: 'Correo electrónico',
                    icon: FontAwesomeIcons.envelope,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || !v.contains('@') ? 'Correo inválido' : null,
                  ),
                  const SizedBox(height: 14),

                  _ClayField(
                    ctrl: _passCtrl,
                    label: 'Contraseña',
                    icon: FontAwesomeIcons.lock,
                    obscure: !_showPass,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _showPass = !_showPass),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: FaIcon(
                          _showPass
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                          size: 14,
                          color: SedixColors.textSecondary,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.circleExclamation,
                              size: 14, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Text(_error!,
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  GestureDetector(
                    onTap: _loading ? null : _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: SedixColors.accent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: SedixColors.accent.withOpacity(0.38),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(FontAwesomeIcons.rightToBracket,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Iniciar sesión',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(
                        color: SedixColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClayField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final FaIconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const _ClayField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboard,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: clayBox(radius: 16),
        child: TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          validator: validator,
          style: const TextStyle(
              color: SedixColors.textPrimary, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
                color: SedixColors.textSecondary, fontSize: 13),
            prefixIcon:
                FaIcon(icon, size: 16, color: SedixColors.textSecondary),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 52, minHeight: 48),
            suffixIcon: suffix,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      );
}
