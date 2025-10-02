import 'package:flutter/material.dart';

class TaskGroups {
  static const String office = 'Office';
  static const String personal = 'Personal';
  static const String daily = 'Daily';
  static const String general = 'General';

  static const List<String> all = [
    office,
    personal,
    daily,
    general,
  ];
}

class TaskGroupIcons {
  static const Map<String, IconData> icons = {
    TaskGroups.office: Icons.work,
    TaskGroups.personal: Icons.person,
    TaskGroups.daily: Icons.calendar_today,
    TaskGroups.general: Icons.star,
  };

  static const Map<String, Color> colors = {
    TaskGroups.daily: Color(0xFFFF7A00),    // cam
    TaskGroups.personal: Color(0xFF6C63FF), // tím
    TaskGroups.office: Color(0xFFFF4D88),   // hồng
    TaskGroups.general: Color(0xFFFFC107),  // vàng
  };
}
