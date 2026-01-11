import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/damu_colors.dart';
import '../../../ui/damu_widgets.dart';
import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../auth/presentation/session_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final session = ref.watch(sessionControllerProvider).valueOrNull;
    final currentLang = session?.user.language ?? 'kz';
    final weight = session?.user.weightKg;

    return Container(
      color: DamuColors.lightBg,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Text(t.profileTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF2B5C8A))),
          const SizedBox(height: 16),
          Center(
            child: DamuAvatar(
              url: session?.user.avatarUrl,
              name: session?.user.fullName,
              size: 82,
              onTap: () async => _pickAndUpload(context, ref),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.languageLabel, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 10),
                _LanguageToggle(
                  value: currentLang,
                  onChanged: (lang) => ref.read(sessionControllerProvider.notifier).updateLanguage(lang),
                  ruLabel: t.languageRu,
                  kzLabel: t.languageKz,
                ),
                const SizedBox(height: 18),
                Text(t.fullNameLabel, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(session?.user.fullName ?? '—', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                Text(t.emailLabel, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(session?.user.email ?? '—', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.weightLabel, style: const TextStyle(color: Colors.black54)),
                    IconButton(
                      onPressed: () => context.push('/onboarding/goal'),
                      icon: const Icon(Icons.edit),
                      color: DamuColors.primary,
                      tooltip: t.setGoalButton,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(weight?.toString() ?? '—', style: const TextStyle(fontSize: 16)),
                    if (weight != null) const SizedBox(width: 6),
                    if (weight != null) const Text('kg', style: TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => ref.read(sessionControllerProvider.notifier).logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE44C4C),
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: Text(t.signOut),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final navContext = Navigator.of(context);
  try {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (res == null || res.files.isEmpty) return;
    final file = res.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Файл не удалось прочитать')));
      return;
    }
    final ext = (file.extension ?? '').toLowerCase();
    final mime = ext == 'png'
        ? 'image/png'
        : ext == 'webp'
            ? 'image/webp'
            : 'image/jpeg';
    await ref.read(sessionControllerProvider.notifier).uploadAvatar(bytes: bytes, filename: file.name, mime: mime);
    if (navContext.mounted) messenger.showSnackBar(const SnackBar(content: Text('Аватар обновлен')));
  } catch (e) {
    if (navContext.mounted) {
      messenger.showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }
}

class _LanguageToggle extends StatelessWidget {
  final String value; // 'ru' | 'kz'
  final ValueChanged<String> onChanged;
  final String ruLabel;
  final String kzLabel;

  const _LanguageToggle({required this.value, required this.onChanged, required this.ruLabel, required this.kzLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F6FB), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Expanded(
            child: _LangChip(
              selected: value == 'ru',
              text: '🇷🇺 $ruLabel',
              onTap: () => onChanged('ru'),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _LangChip(
              selected: value != 'ru',
              text: '🇰🇿 $kzLabel',
              onTap: () => onChanged('kz'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final bool selected;
  final String text;
  final VoidCallback onTap;
  const _LangChip({required this.selected, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBFE7F2) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? const Color(0xFF2F7AD8) : Colors.black87,
          ),
        ),
      ),
    );
  }
}
