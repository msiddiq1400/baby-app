import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Bottom sheet for a small form that stays above the keyboard.
Future<void> showFormSheet(BuildContext context, Widget form) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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

/// Tappable row showing a time of day; opens the time picker.
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.label, required this.time, required this.onChanged});

  final String label;
  final DateTime time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(label),
      trailing: Text(TimeOfDay.fromDateTime(time).format(context), style: Theme.of(context).textTheme.titleMedium),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(time));
        if (picked == null) return;
        var chosen = DateTime(time.year, time.month, time.day, picked.hour, picked.minute);
        // A time later than now means last night, e.g. logging an 11 pm feed after midnight.
        if (chosen.isAfter(DateTime.now())) chosen = chosen.subtract(const Duration(days: 1));
        onChanged(chosen);
      },
    );
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
