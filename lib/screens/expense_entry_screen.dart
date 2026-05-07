import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/participant_provider.dart';

class ExpenseEntryScreen extends StatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  State<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  
  String? _selectedPayerId;
  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Stay', 'Activity', 'Other'];
  List<String> _splitAmongIds = [];

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final partProv = Provider.of<ParticipantProvider>(context);
    final participants = partProv.getParticipantsForTrip(tripId);

    if (_splitAmongIds.isEmpty && participants.isNotEmpty) {
      _splitAmongIds = participants.map((p) => p.id).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹)'),
              onChanged: (_) => setState(() {}),
              validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter valid amount' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            DropdownButtonFormField<String>(
              value: _selectedPayerId,
              decoration: const InputDecoration(labelText: 'Paid By'),
              items: participants.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
              onChanged: (v) => setState(() => _selectedPayerId = v!),
              validator: (v) => v == null ? 'Select payer' : null,
            ),
            const SizedBox(height: 24),
            const Text('Split Among', style: TextStyle(fontWeight: FontWeight.bold)),
            ...participants.map((p) => CheckboxListTile(
              title: Text(p.name),
              value: _splitAmongIds.contains(p.id),
              onChanged: (val) {
                setState(() {
                  if (val!) {
                    _splitAmongIds.add(p.id);
                  } else {
                    _splitAmongIds.remove(p.id);
                  }
                });
              },
            )),
            if (_amountController.text.isNotEmpty && _splitAmongIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Each pays: ₹${(double.tryParse(_amountController.text) ?? 0) / _splitAmongIds.length}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && _splitAmongIds.isNotEmpty) {
                   final exp = Expense(
                    id: const Uuid().v4(),
                    tripId: tripId,
                    amount: double.parse(_amountController.text),
                    description: _descController.text,
                    paidById: _selectedPayerId!,
                    splitAmong: _splitAmongIds,
                    createdAt: DateTime.now(),
                    category: _selectedCategory,
                  );
                  await Provider.of<ExpenseProvider>(context, listen: false).addExpense(exp);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
