import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/baby_age.dart';
import '../../data/models.dart';
import '../../data/photo_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/sheet.dart';

/// Oldest month a photo can be added for (the database allows up to 60).
const _maxMonth = 60;

/// "Newborn", "1 month", "2 months"...
String photoMonthLabel(AppLocalizations l10n, int ageMonth) =>
    ageMonth == 0 ? l10n.photoNewborn : l10n.photoMonths(ageMonth);

/// Growth > Photos: one photo for each month of the baby's age, newest month
/// first. Empty months can be filled in later.
class PhotosView extends ConsumerWidget {
  const PhotosView({super.key, required this.baby});

  final Baby baby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final byMonth = {for (final p in ref.watch(photosProvider(baby.id)).value ?? const <Photo>[]) p.ageMonth: p};
    final current = babyAge(baby.birthDate, DateTime.now()).months.clamp(0, _maxMonth);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.photosIntro(baby.name), style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var m = current; m >= 0; m--) _MonthTile(baby: baby, ageMonth: m, photo: byMonth[m]),
          ],
        ),
      ],
    );
  }
}

class _MonthTile extends ConsumerWidget {
  const _MonthTile({required this.baby, required this.ageMonth, this.photo});

  final Baby baby;
  final int ageMonth;
  final Photo? photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final photo = this.photo;
    final file = photo?.localPath == null ? null : File(photo!.localPath!);

    final Widget content = switch ((photo, file)) {
      (null, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(l10n.addPhoto, style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      (_, final File f) => Image.file(f, fit: BoxFit.cover, cacheWidth: 400, errorBuilder: (_, _, _) => const _Waiting()),
      _ => const _Waiting(),
    };

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => photo == null
            ? addPhoto(context, ref, baby, ageMonth)
            : Navigator.of(context).push(MaterialPageRoute(builder: (_) => PhotoScreen(baby: baby, photo: photo))),
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: photo == null ? null : Colors.black45,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  photoMonthLabel(l10n, ageMonth),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: photo == null ? null : Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The photo hasn't downloaded to this phone yet.
class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) => Center(child: Icon(Icons.cloud_download_outlined, color: Theme.of(context).colorScheme.outline));
}

/// Camera or gallery, then a preview with an optional caption. Photos are
/// shrunk on the phone (1600 px, JPEG) before they're saved and uploaded.
Future<void> addPhoto(BuildContext context, WidgetRef ref, Baby baby, int ageMonth, {String? replacing}) async {
  final l10n = AppLocalizations.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.takePhoto),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.chooseFromGallery),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;
  final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
  if (picked == null || !context.mounted) return;
  final bytes = await picked.readAsBytes();
  if (!context.mounted) return;
  await showFormSheet(context, _SavePhotoSheet(baby: baby, ageMonth: ageMonth, bytes: bytes, replacing: replacing));
}

class _SavePhotoSheet extends ConsumerStatefulWidget {
  const _SavePhotoSheet({required this.baby, required this.ageMonth, required this.bytes, this.replacing});

  final Baby baby;
  final int ageMonth;
  final Uint8List bytes;

  /// Photo this one replaces (deleted first, keeping one per month).
  final String? replacing;

  @override
  ConsumerState<_SavePhotoSheet> createState() => _SavePhotoSheetState();
}

class _SavePhotoSheetState extends ConsumerState<_SavePhotoSheet> {
  final _caption = TextEditingController();
  var _busy = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = ref.read(photoRepositoryProvider);
    final caption = _caption.text.trim();
    try {
      if (widget.replacing case final old?) await repo.delete(widget.baby, old);
      await repo.add(widget.baby, ageMonth: widget.ageMonth, jpeg: widget.bytes, caption: caption.isEmpty ? null : caption);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is PhotoLimitException ? l10n.photoMonthTaken : l10n.errorGeneric)),
      );
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(photoMonthLabel(l10n, widget.ageMonth), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Image.memory(widget.bytes, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _caption,
          maxLength: 200,
          decoration: InputDecoration(labelText: l10n.photoCaptionLabel),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 8),
        FilledButton(onPressed: _busy ? null : _save, child: Text(l10n.saveButton)),
      ],
    );
  }
}

/// One photo, full screen: share, replace, edit the caption or delete.
class PhotoScreen extends ConsumerWidget {
  const PhotoScreen({super.key, required this.baby, required this.photo});

  final Baby baby;
  final Photo photo;

  Future<void> _editCaption(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: photo.caption ?? '');
    final caption = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
          maxLength: 200,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.photoCaptionLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(l10n.saveButton)),
        ],
      ),
    );
    controller.dispose();
    if (caption != null) {
      await ref.read(photoRepositoryProvider).updateCaption(photo.id, caption.isEmpty ? null : caption);
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final path = photo.localPath;
    final label = photoMonthLabel(l10n, photo.ageMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text('${baby.name} · $label'),
        actions: [
          if (path != null)
            IconButton(
              tooltip: l10n.shareButton,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => SharePlus.instance.share(
                ShareParams(files: [XFile(path, mimeType: 'image/jpeg')], text: '${baby.name} · $label'),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: path == null
                ? const _Waiting()
                : InteractiveViewer(child: Center(child: Image.file(File(path), errorBuilder: (_, _, _) => const _Waiting()))),
          ),
          if (photo.caption case final caption?)
            Padding(padding: const EdgeInsets.all(16), child: Text(caption, style: theme.textTheme.bodyLarge)),
          SafeArea(
            top: false,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.editCaption),
                  onPressed: () => _editCaption(context, ref),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(l10n.replacePhoto),
                  onPressed: () async {
                    await addPhoto(context, ref, baby, photo.ageMonth, replacing: photo.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                DeleteButton(
                  onConfirmed: () async {
                    await ref.read(photoRepositoryProvider).delete(baby, photo.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
