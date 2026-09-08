import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeProvider);
    final fontScale = ref.watch(fontScaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: userProfileAsync.when(
        data: (user) {
          final isScholar = user?.role == 'scholar';

          return ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // User Card
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF1B3B5A),
                  child: Text(
                    (user?.name.isNotEmpty == true ? user!.name[0] : 'M').toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  user?.name.isNotEmpty == true ? user!.name : 'Muntazir User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${user?.email ?? ''}\nMarja: ${user?.marja.toUpperCase() ?? 'SISTANI'}',
                  style: const TextStyle(height: 1.4),
                ),
                trailing: isScholar
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('SCHOLAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black)),
                      )
                    : null,
              ),
              const SizedBox(height: 24),

              // Scholar Question Queue Section
              Text(
                'Scholar Portal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFC27351),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: const Color(0xFFC27351).withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.school_rounded, color: Color(0xFFC27351)),
                title: const Text('Scholar Question Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Review and answer community fiqh questions'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  context.push('/scholar-dashboard');
                },
              ),
              const SizedBox(height: 24),

              // Appearance Settings
              Text('Appearance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme Mode'),
                trailing: DropdownButton<ThemeMode>(
                  value: currentThemeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      final str = ref.read(themeProvider.notifier).themeModeToString(mode);
                      ref.read(themeProvider.notifier).setTheme(str);
                      if (user != null) {
                        ref.read(userServiceProvider).updateUserField(user.uid, 'theme', str);
                      }
                    }
                  },
                ),
              ),

              // Font Size Slider (Mandatory requirement from Section 4)
              ListTile(
                leading: const Icon(Icons.format_size_rounded),
                title: const Text('Text Size Scaling'),
                subtitle: Slider(
                  value: fontScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${(fontScale * 100).round()}%',
                  onChanged: (val) {
                    ref.read(fontScaleProvider.notifier).setScale(val);
                  },
                ),
              ),
              const Divider(height: 32),

              // Language & Marja
              Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Language'),
                subtitle: Text(_getLanguageName(user?.language ?? 'en')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showLanguagePicker(context, ref, user?.language ?? 'en', user?.uid),
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_rounded),
                title: const Text('Marja-e-Taqleed'),
                subtitle: Text(user?.marja.toUpperCase() ?? 'SISTANI'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showMarjaPicker(context, ref, user?.marja ?? 'sistani', user?.uid),
              ),
              const Divider(height: 32),

              // Sign out / Re-run onboarding
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Re-run Onboarding Setup'),
                onTap: () => context.go('/onboarding'),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await ref.read(userServiceProvider).signOut();
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ur':
        return 'Urdu (اردو)';
      case 'hi':
        return 'Hindi / Transliteration (हिंदी)';
      case 'gu':
        return 'Gujarati (ગુજરાતી)';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentLang, String? uid) {
    final languages = [
      {'code': 'en', 'title': 'English (Default App Language)'},
      {'code': 'ur', 'title': 'Urdu (اردو ترجمہ)'},
      {'code': 'hi', 'title': 'Hindi / Hinglish (हिंदी अनुवाद)'},
      {'code': 'gu', 'title': 'Gujarati (ગુજરાતી અનુવાદ)'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select App Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ...languages.map((l) {
                final isSelected = currentLang == l['code'];
                return ListTile(
                  title: Text(l['title']!, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC27351)) : null,
                  onTap: () {
                    if (uid != null) {
                      ref.read(userServiceProvider).updateUserField(uid, 'language', l['code']!);
                    }
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language updated to ${l['title']}!')),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showMarjaPicker(BuildContext context, WidgetRef ref, String currentMarja, String? uid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Marja-e-Taqleed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ListTile(
                title: const Text('Grand Ayatollah Sayyid Ali al-Sistani', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Najaf al-Ashraf'),
                trailing: currentMarja.toLowerCase().contains('sistani') ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC27351)) : null,
                onTap: () {
                  if (uid != null) {
                    ref.read(userServiceProvider).updateUserField(uid, 'marja', 'sistani');
                  }
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marja updated to Ayatollah Sistani.')),
                  );
                },
              ),
              ListTile(
                title: const Text('Grand Ayatollah Sayyid Ali Khamenei', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tehran / Qum'),
                trailing: currentMarja.toLowerCase().contains('khamenei') ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC27351)) : null,
                onTap: () {
                  if (uid != null) {
                    ref.read(userServiceProvider).updateUserField(uid, 'marja', 'khamenei');
                  }
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marja updated to Ayatollah Khamenei.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
