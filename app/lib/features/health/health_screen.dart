import 'package:flutter/material.dart';

import '../../core/reminders.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import 'medicines_view.dart';
import 'symptoms_view.dart';
import 'vaccines_view.dart';

/// Health tab: vaccines, medicines and the symptom diary.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key, required this.baby});

  final Baby baby;

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Asked here, where reminders make sense, rather than at app start.
    Reminders.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthTitle),
          actions: const [LanguageMenu(showSignOut: true)],
          bottom: TabBar(
            tabs: [Tab(text: l10n.tabVaccines), Tab(text: l10n.tabMedicines), Tab(text: l10n.tabSymptoms)],
          ),
        ),
        body: TabBarView(
          children: [
            VaccinesView(baby: widget.baby),
            MedicinesView(baby: widget.baby),
            SymptomsView(baby: widget.baby),
          ],
        ),
      ),
    );
  }
}
