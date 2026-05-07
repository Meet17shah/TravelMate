import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/participant_model.dart';

class ParticipantProvider with ChangeNotifier {
  final Box<Participant> _box = Hive.box<Participant>('participants');

  List<Participant> getParticipantsForTrip(String tripId) {
    return _box.values.where((p) => p.tripId == tripId).toList();
  }

  Future<void> addParticipant(Participant participant) async {
    await _box.put(participant.id, participant);
    notifyListeners();
  }

  Future<void> deleteParticipant(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
