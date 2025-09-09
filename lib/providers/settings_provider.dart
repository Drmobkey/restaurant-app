import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDailyReminderEnabled = false;
  static const String _reminderKey = 'isDailyReminderEnabled';

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDailyReminderEnabled = prefs.getBool(_reminderKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleDailyReminder() async {
    _isDailyReminderEnabled = !_isDailyReminderEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, _isDailyReminderEnabled);
    
    if (_isDailyReminderEnabled) {
      await NotificationService.scheduleDaily();
    } else {
      await NotificationService.cancelDaily();
    }
    
    notifyListeners();
  }

  Future<void> setDailyReminder(bool value) async {
    _isDailyReminderEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, _isDailyReminderEnabled);
    
    if (_isDailyReminderEnabled) {
      await NotificationService.scheduleDaily();
    } else {
      await NotificationService.cancelDaily();
    }
    
    notifyListeners();
  }
}