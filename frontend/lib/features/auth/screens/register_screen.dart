import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _step = 0;

  // Step 1 — Account
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _form1 = GlobalKey<FormState>();

  // Step 2 — Personal
  final _phoneCtrl = TextEditingController();
  String? _country;
  DateTime? _dob;

  // Step 3 — Preferences
  String _currency = 'USD';
  final _goalCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  static const _countries = [
    'Mexico', 'United States', 'Argentina', 'Colombia',
    'Chile', 'Spain', 'Peru', 'Venezuela', 'Ecuador', 'Other',
  ];

  static const _currencies = [
    ('USD', '\$ Dollar'),
    ('MXN', '\$ Peso MX'),
    ('EUR', '€ Euro'),
    ('ARS', '\$ Peso AR'),
    ('COP', '\$ Peso CO'),
    ('CLP', '\$ Peso CL'),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _phoneCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && !(_form1.currentState?.validate() ?? false)) return;
    if (_step < 2) {
      setState(() => _step++);
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post<Map<String, dynamic>>('/auth/register', data: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        if (_country != null) 'country': _country,
        if (_dob != null)
          'dateOfBirth': _dob!.toIso8601String().split('T').first,
        'currency': _currency,
        if (_goalCtrl.text.trim().isNotEmpty)
          'monthlyGoal': double.tryParse(_goalCtrl.text.trim()),
      });
      await ref.read(authNotifierProvider.notifier).saveToken(res.data!['token']);
      if (mounted) context.go('/');
    } catch (_) {
      setState(() => _error = 'Registration failed. Email may already be in use.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SedixColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(step: _step, onBack: _step > 0 ? _prevStep : null),
            _StepIndicator(step: _step),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1(
                    formKey: _form1,
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    passCtrl: _passCtrl,
                  ),
                  _Step2(
                    phoneCtrl: _phoneCtrl,
                    country: _country,
                    dob: _dob,
                    countries: _countries,
                    onCountry: (v) => setState(() => _country = v),
                    onDob: (d) => setState(() => _dob = d),
                  ),
                  _Step3(
                    currency: _currency,
                    currencies: _currencies,
                    goalCtrl: _goalCtrl,
                    onCurrency: (v) => setState(() => _currency = v),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(_error!,
                      style: TextStyle(
                          color: Colors.red.shade700, fontSize: 13)),
                ),
              ),
            _BottomBar(
              step: _step,
              loading: _loading,
              onNext: _nextStep,
              onLogin: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int step;
  final VoidCallback? onBack;

  const _TopBar({required this.step, this.onBack});

  static const _titles = ['Create account', 'About you', 'Your preferences'];
  static const _subs = [
    'Set up your login credentials',
    'Help us personalize your experience',
    'Set your savings preferences',
  ];

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: clayBox(radius: 12),
                  child: const FaIcon(FontAwesomeIcons.chevronLeft,
                      size: 14, color: SedixColors.textPrimary),
                ),
              )
            else
              const SizedBox(width: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[step],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: SedixColors.textPrimary,
                    ),
                  ),
                  Text(
                    _subs[step],
                    style: const TextStyle(
                      fontSize: 12,
                      color: SedixColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Step indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: List.generate(3, (i) {
            final done = i < step;
            final active = i == step;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      decoration: BoxDecoration(
                        color: done || active
                            ? SedixColors.accent
                            : SedixColors.shadowDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 6),
                ],
              ),
            );
          }),
        ),
      );
}

// ── Step 1: Account ───────────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;

  const _Step1({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: clayBox(radius: 48),
                child: const FaIcon(FontAwesomeIcons.circleUser,
                    size: 44, color: SedixColors.accent),
              ),
              const SizedBox(height: 28),
              _ClayField(
                ctrl: nameCtrl,
                label: 'Full name',
                icon: FontAwesomeIcons.idCard,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _ClayField(
                ctrl: emailCtrl,
                label: 'Email address',
                icon: FontAwesomeIcons.envelope,
                keyboard: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 14),
              _ClayField(
                ctrl: passCtrl,
                label: 'Password',
                icon: FontAwesomeIcons.lock,
                obscure: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
            ],
          ),
        ),
      );
}

// ── Step 2: Personal ──────────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final String? country;
  final DateTime? dob;
  final List<String> countries;
  final ValueChanged<String?> onCountry;
  final ValueChanged<DateTime> onDob;

  const _Step2({
    required this.phoneCtrl,
    required this.country,
    required this.dob,
    required this.countries,
    required this.onCountry,
    required this.onDob,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: clayBox(radius: 48),
              child: const FaIcon(FontAwesomeIcons.earthAmericas,
                  size: 44, color: SedixColors.accent),
            ),
            const SizedBox(height: 28),

            // Phone
            _ClayField(
              ctrl: phoneCtrl,
              label: 'Phone (optional)',
              icon: FontAwesomeIcons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // Country dropdown
            Container(
              decoration: clayBox(radius: 16),
              child: DropdownButtonFormField<String>(
                value: country,
                hint: const Text('Country',
                    style: TextStyle(
                        color: SedixColors.textSecondary, fontSize: 14)),
                decoration: const InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: FaIcon(FontAwesomeIcons.flag,
                        color: SedixColors.textSecondary, size: 16),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: countries
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: onCountry,
              ),
            ),
            const SizedBox(height: 14),

            // Date of birth
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now().subtract(
                      const Duration(days: 365 * 13)),
                );
                if (picked != null) onDob(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 18),
                decoration: clayBox(radius: 16),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.cakeCandles,
                        color: SedixColors.textSecondary, size: 16),
                    const SizedBox(width: 12),
                    Text(
                      dob == null
                          ? 'Date of birth (optional)'
                          : '${dob!.day}/${dob!.month}/${dob!.year}',
                      style: TextStyle(
                        color: dob == null
                            ? SedixColors.textSecondary
                            : SedixColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const FaIcon(FontAwesomeIcons.calendarDay,
                        color: SedixColors.textSecondary, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

// ── Step 3: Preferences ───────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final String currency;
  final List<(String, String)> currencies;
  final TextEditingController goalCtrl;
  final ValueChanged<String> onCurrency;

  const _Step3({
    required this.currency,
    required this.currencies,
    required this.goalCtrl,
    required this.onCurrency,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: clayBox(radius: 48),
                child: const FaIcon(FontAwesomeIcons.coins,
                    size: 44, color: SedixColors.accent),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Currency',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SedixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Currency grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: currencies.map((c) {
                final selected = c.$1 == currency;
                return GestureDetector(
                  onTap: () => onCurrency(c.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? SedixColors.accent
                          : SedixColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: SedixColors.accent.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.85),
                                offset: const Offset(-4, -4),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color:
                                    SedixColors.shadowDark.withOpacity(0.55),
                                offset: const Offset(4, 4),
                                blurRadius: 10,
                              ),
                            ],
                    ),
                    child: Text(
                      c.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: selected
                            ? Colors.white
                            : SedixColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              'Monthly savings goal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SedixColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            _ClayField(
              ctrl: goalCtrl,
              label: 'Amount (optional)',
              icon: FontAwesomeIcons.piggyBank,
              keyboard:
                  const TextInputType.numberWithOptions(decimal: true),
              prefix: '\$ ',
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SedixColors.accentLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  FaIcon(FontAwesomeIcons.lightbulb,
                      size: 16, color: SedixColors.accent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Setting a monthly goal helps your AI advisor give better tips.',
                      style: TextStyle(
                        fontSize: 12,
                        color: SedixColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int step;
  final bool loading;
  final VoidCallback onNext;
  final VoidCallback onLogin;

  const _BottomBar({
    required this.step,
    required this.loading,
    required this.onNext,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          children: [
            GestureDetector(
              onTap: loading ? null : onNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color:
                      loading ? SedixColors.shadowDark : SedixColors.accent,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: loading
                      ? []
                      : [
                          BoxShadow(
                            color: SedixColors.accent.withOpacity(0.38),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        step < 2 ? 'Continue →' : 'Create account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
            if (step == 0) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onLogin,
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    color: SedixColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

// ── Clay text field ───────────────────────────────────────────────────────────

class _ClayField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final String? prefix;

  const _ClayField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboard,
    this.validator,
    this.prefix,
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
            color: SedixColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            prefixText: prefix,
            labelStyle: const TextStyle(
              color: SedixColors.textSecondary,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: FaIcon(icon, color: SedixColors.textSecondary, size: 16),
            ),
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
