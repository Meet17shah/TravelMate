import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/itinerary_item_model.dart';
import '../providers/itinerary_provider.dart';
import '../providers/trip_provider.dart';
import '../utils/formatters.dart';

class ItineraryPlanningScreen extends StatefulWidget {
  const ItineraryPlanningScreen({super.key});

  @override
  State<ItineraryPlanningScreen> createState() => _ItineraryPlanningScreenState();
}

class _ItineraryPlanningScreenState extends State<ItineraryPlanningScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final trip = Provider.of<TripProvider>(context).trips.firstWhere((t) => t.id == tripId);
    final itinProv = Provider.of<ItineraryProvider>(context);

    _selectedDate ??= trip.startDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Itinerary')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<DateTime>(
                    value: _selectedDate,
                    items: List.generate(
                      trip.endDate.difference(trip.startDate).inDays + 1,
                      (i) => trip.startDate.add(Duration(days: i)),
                    ).map((d) => DropdownMenuItem(value: d, child: Text(Formatters.formatDate(d)))).toList(),
                    onChanged: (v) => setState(() => _selectedDate = v),
                    decoration: const InputDecoration(labelText: 'Date'),
                  ),
                  TextFormField(
                    controller: _activityController,
                    decoration: const InputDecoration(labelText: 'Activity'),
                    validator: (v) => v!.length < 3 ? 'Too short' : null,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _timeController,
                          decoration: const InputDecoration(labelText: 'Time (Optional)'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) _timeController.text = time.format(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final item = ItineraryItem(
                          id: const Uuid().v4(),
                          tripId: tripId,
                          date: _selectedDate!,
                          activity: _activityController.text,
                          time: _timeController.text,
                          notes: _notesController.text,
                        );
                        await itinProv.addItem(item);
                        _activityController.clear();
                        _timeController.clear();
                        _notesController.clear();
                      }
                    },
                    child: const Text('Add Activity'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: itinProv.getItemsForTrip(tripId)
                  .where((item) => item.date.day == _selectedDate!.day)
                  .map((item) => Dismissible(
                        key: Key(item.id),
                        onDismissed: (_) => itinProv.deleteItem(item.id),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, child: const Icon(Icons.delete)),
                        child: ListTile(
                          title: Text(item.activity),
                          subtitle: Text(item.time ?? ''),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
