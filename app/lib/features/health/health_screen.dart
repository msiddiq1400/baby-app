import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/topic_icons.dart';
import '../../core/reminders.dart';
import '../../data/models.dart';
import '../../data/symptom_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/language_menu.dart';
import '../common/tab_title.dart';
import 'doctor_summary_screen.dart';
import 'medicines_view.dart';
import 'symptoms_view.dart';
import 'vaccines_view.dart';

/// Health tab: the summary for the doctor at the top, then vaccines,
/// medicines and the symptom diary.
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key, required this.baby});

  final Baby baby;

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Asked here, where reminders make sense, rather than at app start.
    Reminders.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final baby = widget.baby;
    // The summary uses the last 14 days to find when symptoms started.
    final recentSymptoms = ref.watch(recentSymptomsProvider(baby.id)).value ?? const <SymptomLog>[];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: TabTitle(title: l10n.healthTitle, baby: baby),
          actions: const [MainActions()],
        ),
        // Not in the app bar: the button sizes itself to the text (Urdu
        // script is taller).
        body: Column(
          children: [
            // For a check-up, whichever tab is open.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DoctorSummaryScreen(baby: baby, recentSymptoms: recentSymptoms),
                    ),
                  ),
                  icon: const Icon(TopicIcons.doctorSummary),
                  label: Text(l10n.doctorSummary, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
            TabBar(
              tabs: [Tab(text: l10n.tabVaccines), Tab(text: l10n.tabMedicines), Tab(text: l10n.tabSymptoms)],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  VaccinesView(baby: baby),
                  MedicinesView(baby: baby),
                  SymptomsView(baby: baby),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
