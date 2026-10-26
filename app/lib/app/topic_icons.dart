import 'package:flutter/material.dart';

/// One icon per topic, used everywhere the topic appears (buttons, cards,
/// tabs, the timeline, the journal, reports), so an icon always means the
/// same thing. Filled versions are for buttons and selected tabs.
abstract final class TopicIcons {
  /// A feed of any kind (breast, bottle, formula): a cup.
  static const feed = Icons.local_drink_outlined;
  static const feedFilled = Icons.local_drink;

  static const sleep = Icons.bedtime_outlined;
  static const sleepFilled = Icons.bedtime;

  static const diaper = Icons.baby_changing_station_outlined;
  static const diaperFilled = Icons.baby_changing_station;

  /// Breast milk: pumping and the stored-milk stash (a drop, not the cup).
  static const milk = Icons.water_drop_outlined;

  /// Solid food, and the Feeding tab (milk stash + solids).
  static const food = Icons.restaurant_outlined;
  static const foodFilled = Icons.restaurant;

  /// Growth: the tab, measurements in the journal and the add button.
  static const growth = Icons.monitor_weight_outlined;
  static const growthFilled = Icons.monitor_weight;

  /// The Health tab.
  static const health = Icons.medical_services_outlined;
  static const healthFilled = Icons.medical_services;

  static const vaccine = Icons.vaccines_outlined;
  static const medicine = Icons.medication_outlined;
  static const symptom = Icons.thermostat_outlined;
  static const illness = Icons.sick_outlined;
  static const doctorVisit = Icons.local_hospital_outlined;
  static const doctorSummary = Icons.description_outlined;
  static const milestone = Icons.emoji_events_outlined;
  static const journal = Icons.menu_book_outlined;
}
