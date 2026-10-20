import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Space under a bottom sheet's content: above the keyboard when it's open,
/// otherwise clear of the phone's home / back / menu buttons (at least 30).
double sheetBottomSpace(BuildContext context) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  if (keyboard > 0) return keyboard;
  return math.max(MediaQuery.viewPaddingOf(context).bottom, 30);
}

/// Bottom sheet for a small form that stays above the keyboard and the
/// phone's navigation buttons.
Future<void> showFormSheet(BuildContext context, Widget form) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: sheetBottomSpace(context)),
      child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), child: form),
    ),
  );
}

/// Runs a save or delete, calls [onDone] (usually to refresh data) and closes
/// the sheet; on failure shows an error and keeps the sheet open.
Future<void> runAndClose(BuildContext context, Future<void> Function() action, {required VoidCallback onDone}) async {
  try {
    await action();
    onDone();
    if (context.mounted) Navigator.pop(context);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).errorGeneric)));
    }
  }
}

/// Tappable row showing a time of day; opens the time picker. With
/// [firstDate], it also has a day button (Today, Yesterday, a date) for
/// logging something from an earlier day.
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.label, required this.time, required this.onChanged, this.firstDate});

  final String label;
  final DateTime time;
  final ValueChanged<DateTime> onChanged;

  /// The earliest day that can be picked (e.g. the baby's birth date).
  final DateTime? firstDate;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
    if (picked == null) return;
    var chosen = DateTime(time.year, time.month, time.day, picked.hour, picked.minute);
    // A time later than now means last night, e.g. logging an 11 pm feed after midnight.
    if (chosen.isAfter(DateTime.now())) chosen = chosen.subtract(const Duration(days: 1));
    onChanged(chosen);
  }

  Future<void> _pickDay(BuildContext context, DateTime first) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: time.isBefore(first) ? first : time,
      firstDate: first,
      lastDate: now,
    );
    if (picked == null) return;
    final chosen = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
    // Today at a time that hasn't come yet: use now instead.
    onChanged(chosen.isAfter(now) ? now : chosen);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = Text(TimeOfDay.fromDateTime(time).format(context), style: theme.textTheme.titleMedium);
    final first = firstDate;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(label),
      trailing: first == null
          ? timeText
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickDay(context, first),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(_dayLabel(context, time)),
                ),
                const SizedBox(width: 12),
                timeText,
              ],
            ),
      onTap: () => _pickTime(context),
    );
  }

  static String _dayLabel(BuildContext context, DateTime t) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final day = DateTime(t.year, t.month, t.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return l10n.tabToday;
    if (day == DateTime(today.year, today.month, today.day - 1)) return l10n.yesterday;
    return MaterialLocalizations.of(context).formatShortMonthDay(t);
  }
}

/// Tappable row showing a date; opens the date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.date,
    required this.firstDate,
    required this.onChanged,
  });

  final String label;
  final DateTime date;
  final DateTime firstDate;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: Text(label),
      trailing: Text(
        MaterialLocalizations.of(context).formatMediumDate(date),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: firstDate,
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// "Delete" text button that asks for confirmation first.
class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.onConfirmed, this.enabled = true});

  final Future<void> Function() onConfirmed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = Theme.of(context).colorScheme.error;
    return TextButton.icon(
      style: TextButton.styleFrom(foregroundColor: color),
      icon: const Icon(Icons.delete_outline),
      label: Text(l10n.deleteButton),
      onPressed: !enabled
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.deleteConfirmTitle),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancelButton)),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: color),
                      child: Text(l10n.deleteButton),
                    ),
                  ],
                ),
              );
              if (confirmed == true) await onConfirmed();
            },
    );
  }
}
