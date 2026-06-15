import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/goals_provider.dart';

class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _deadline;
  String _emoji = '🏦';
  bool _loading = false;

  static const _emojis = ['🏦', '🚗', '🏠', '✈️', '🎓', '💻', '👗', '💍', '🐾', '🎮'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await ref.read(goalsProvider.notifier).createGoal({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'targetAmount': double.parse(_amountCtrl.text),
        'deadline': _deadline?.toIso8601String(),
        'emoji': _emoji,
      });
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nueva meta de ahorro',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _emojis
                  .map((e) => ChoiceChip(
                        label: Text(e),
                        selected: _emoji == e,
                        onSelected: (_) => setState(() => _emoji = e),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la meta'),
              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                  labelText: 'Monto objetivo', prefixText: '\$ '),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null || n <= 0 ? 'Ingresa un monto válido' : null;
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.calendarDay, size: 14),
              label: Text(_deadline == null
                  ? 'Establecer fecha límite (opcional)'
                  : 'Fecha límite: ${_deadline!.toLocal().toString().split(' ')[0]}'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Crear meta'),
            ),
          ],
        ),
      ),
    );
  }
}
