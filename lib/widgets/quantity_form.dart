// lib/widgets/quantity_form.dart

import 'package:flutter/material.dart';
import '../utils/validators.dart';

class QuantityForm extends StatefulWidget {
  final void Function(double clearKg, double colouredKg, String condition) onSubmit;

  const QuantityForm({super.key, required this.onSubmit});

  @override
  State<QuantityForm> createState() => _QuantityFormState();
}

class _QuantityFormState extends State<QuantityForm> {
  final _formKey   = GlobalKey<FormState>();
  final _clearCtrl = TextEditingController();
  final _colCtrl   = TextEditingController();
  String? _condition;

  @override
  void dispose() {
    _clearCtrl.dispose();
    _colCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        double.parse(_clearCtrl.text.trim()),
        double.parse(_colCtrl.text.trim()),
        _condition!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clear glass field
          TextFormField(
            controller: _clearCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Clear Glass (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.water),
            ),
            validator: Validators.validateKg,
          ),
          const SizedBox(height: 12),

          // Coloured glass field
          TextFormField(
            controller: _colCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Coloured Glass (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.color_lens),
            ),
            validator: Validators.validateKg,
          ),
          const SizedBox(height: 12),

          // Condition dropdown - use initialValue pattern (no deprecated 'value' on DropdownButtonFormField)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Condition',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info_outline),
            ),
            items: const [
              DropdownMenuItem(value: 'Good', child: Text('Good')),
              DropdownMenuItem(value: 'Fair', child: Text('Fair')),
              DropdownMenuItem(value: 'Poor', child: Text('Poor')),
            ],
            onChanged: (v) => setState(() => _condition = v),
            validator: Validators.validateCondition,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text(
                'Confirm Collection',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
