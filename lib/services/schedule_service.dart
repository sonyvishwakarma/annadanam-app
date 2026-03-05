import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleService {
  static const String _scheduleKey = 'recurring_donations';

  Future<void> saveSchedule(Map<String, dynamic> schedule) async {
    final prefs = await SharedPreferences.getInstance();
    final schedules = await getSchedules();
    schedules.add(schedule);

    await prefs.setString(_scheduleKey, json.encode(schedules));
  }

  Future<List<Map<String, dynamic>>> getSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_scheduleKey);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> deleteSchedule(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final schedules = await getSchedules();
    schedules.removeWhere((schedule) => schedule['id'] == id);

    await prefs.setString(_scheduleKey, json.encode(schedules));
  }

  static List<DateTime> generateSchedule({
    required List<String> days,
    required TimeOfDay time,
    required int weeks,
    int count = 10,
  }) {
    List<DateTime> dates = [];
    final now = DateTime.now();

    for (int week = 0; week < weeks; week++) {
      for (final day in days) {
        DateTime date = _getNextDateForDay(day, now.add(Duration(days: week * 7)));
        dates.add(DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));

        if (dates.length >= count) break;
      }
      if (dates.length >= count) break;
    }

    return dates.take(count).toList();
  }

  static DateTime _getNextDateForDay(String dayName, DateTime fromDate) {
    final days = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    int targetDay = days[dayName.toLowerCase()] ?? 1;
    DateTime date = fromDate;

    while (date.weekday != targetDay) {
      date = date.add(const Duration(days: 1));
    }

    return date;
  }
}