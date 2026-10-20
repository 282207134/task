import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Small app-wide state store. Writes are serialized so rapid edits cannot race.
class AppStore extends ChangeNotifier {
  AppStore(this._preferences);
  final SharedPreferences _preferences;
  static const storageKey = 'taskflow.state.v1';
  List<TaskCard> _cards = [];
  List<bool> _checked = [true, false, false, false, false];
  List<String> _agenda = List.of(defaultAgenda);
  List<String> _participants = memberNames.take(3).toList();
  String name = 'Quiche Hollandaise', role = 'UI Designer';
  bool notifications = true;
  String? error;
  Future<void> _pending = Future.value();

  List<TaskCard> get cards => List.unmodifiable(_cards);
  List<bool> get checked => List.unmodifiable(_checked);
  List<String> get agenda => List.unmodifiable(_agenda);
  List<String> get participants => List.unmodifiable(_participants);

  static Future<AppStore> load() async {
    final store = AppStore(await SharedPreferences.getInstance());
    final raw = store._preferences.getString(storageKey);
    if (raw == null) return store;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final cards = (data['cards'] as List)
          .map((e) => TaskCard.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final agenda = List<String>.from(data['agenda'] as List);
      final checked = List<bool>.from(data['checked'] as List);
      if (agenda.length != checked.length) throw const FormatException();
      store._cards = cards;
      store._agenda = agenda;
      store._checked = checked;
      store._participants = List<String>.from(data['participants'] as List);
      store.name = data['name'] as String;
      store.role = data['role'] as String;
      store.notifications = data['notifications'] as bool;
    } catch (_) {
      store.error = 'Saved data could not be read. Showing the demo workspace.';
    }
    return store;
  }

  Future<void> _save() {
    final snapshot = jsonEncode({
      'cards': _cards.map((c) => c.toJson()).toList(),
      'agenda': _agenda,
      'checked': _checked,
      'participants': _participants,
      'name': name,
      'role': role,
      'notifications': notifications,
    });
    _pending = _pending.then((_) async {
      try {
        if (!await _preferences.setString(storageKey, snapshot)) {
          throw StateError('Save failed');
        }
        error = null;
      } catch (_) {
        error = 'Could not save changes. Please try again.';
      }
      notifyListeners();
    });
    notifyListeners();
    return _pending;
  }

  Future<void> saveCard(TaskCard card) {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index < 0) {
      _cards.add(card);
    } else {
      _cards[index] = card;
    }
    return _save();
  }

  Future<void> toggleAgenda(int index) {
    _checked[index] = !_checked[index];
    return _save();
  }

  Future<void> updateAgenda(List<String> values) {
    final old = Map.fromIterables(_agenda, _checked);
    _agenda = values;
    _checked = values.map((v) => old[v] ?? false).toList();
    return _save();
  }

  Future<void> setParticipants(List<String> values) {
    _participants = List.of(values);
    return _save();
  }

  Future<void> updateProfile(String value, String job, bool alerts) {
    name = value;
    role = job;
    notifications = alerts;
    return _save();
  }
}
