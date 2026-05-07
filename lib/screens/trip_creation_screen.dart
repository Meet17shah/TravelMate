import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';
import '../models/participant_model.dart';
import '../providers/trip_provider.dart';
import '../providers/participant_provider.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  State<TripCreationScreen> createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _participantController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  final List<Participant> _participants = [];

  void _addParticipant() {
    final name = _participantController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        _participants.add(Participant(
          id: const Uuid().v4(),
          name: name,
          tripId: '', // Will be updated on save
          avatarColorHex: '0xFFE94560',
        ));
        _participantController.clear();
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null && _participants.isNotEmpty) {
      final tripId = const Uuid().v4();
      final newTrip = Trip(
        id: tripId,
        name: _nameController.text,
        destination: _destinationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        participantIds: _participants.map((p) => p.id).toList(),
        createdAt: DateTime.now(),
      );

      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      final partProvider = Provider.of<ParticipantProvider>(context, listen: false);

      await tripProvider.addTrip(newTrip);
      for (var p in _participants) {
        p.tripId = tripId;
        await partProvider.addParticipant(p);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Trip Name'),
              validator: (v) => (v == null || v.length < 3) ? 'Min 3 characters' : null,
            ),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(_startDate == null ? 'Select' : Formatters.formatDate(_startDate!)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate == null ? 'Select' : Formatters.formatDate(_endDate!)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: _startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text('Participants', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _participantController,
                    decoration: const InputDecoration(hintText: 'Enter name'),
                  ),
                ),
                IconButton(onPressed: _addParticipant, icon: const Icon(Icons.add_circle, color: AppTheme.highlight)),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _participants.map((p) => Chip(
                label: Text(p.name),
                onDeleted: () => setState(() => _participants.remove(p)),
              )).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTrip,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.highlight, padding: const EdgeInsets.all(16)),
              child: const Text('Create Trip', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
