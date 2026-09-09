import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/companion_models.dart';
import '../../models/goal_model.dart';
import '../../models/user_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/reader_preferences_service.dart';
import '../main_navigation_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final userGoalsAsync = ref.watch(userGoalsStreamProvider);
    final weekStreakAsync = ref.watch(weekStreakStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      drawer: userProfileAsync.value != null
          ? _buildAppDrawer(context, ref, userProfileAsync.value!, isDark)
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              size: 26,
            ),
            tooltip: 'Navigation Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Muntazir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.help_outline_rounded,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          final greetingName = user?.name.isNotEmpty == true ? user!.name : 'Ali';
          final initial = greetingName.isNotEmpty ? greetingName[0].toUpperCase() : 'A';

          return userGoalsAsync.when(
            data: (goals) {
              final weekLogs = weekStreakAsync.value ?? [];
              return _buildHomeBody(
                context,
                ref,
                greetingName,
                initial,
                goals,
                weekLogs,
                isDark,
                user?.uid ?? 'guest_user',
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFC27351)),
            ),
            error: (err, _) => Center(child: Text('Error loading goals: $err')),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC27351)),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHomeBody(
    BuildContext context,
    WidgetRef ref,
    String greetingName,
    String initial,
    List<GoalModel> goals,
    List<StreakLogModel> weekLogs,
    bool isDark,
    String userId,
  ) {
    // Compute total items and completed recitations today
    int totalPlanned = 0;
    int totalCompleted = 0;
    int maxStreak = 0;

    for (final g in goals) {
      final itemsCount = g.items.length;
      totalPlanned += itemsCount;
      final completedInGoal = (g.progressToday * itemsCount).round();
      totalCompleted += completedInGoal;
      if (g.streakCount > maxStreak) {
        maxStreak = g.streakCount;
      }
    }

    final overallPercentage = totalPlanned > 0
        ? ((totalCompleted / totalPlanned) * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      children: [
        // Top Greeting Row (C.9)
        _buildGreetingHeader(greetingName, initial, isDark),
        const SizedBox(height: 18),

        // Hero: "YOUR DAILY NIYYAH" Card
        _buildDailyNiyyahCard(
          totalCompleted: totalCompleted,
          totalPlanned: totalPlanned,
          percentage: overallPercentage,
        ),
        const SizedBox(height: 20),

        // Recitation of the Day (C.7)
        _buildRecitationOfTheDay(context, isDark),
        const SizedBox(height: 20),

        // Hadith of the Day (C.8)
        _buildHadithOfTheDay(isDark),
        const SizedBox(height: 20),

        // Favorites Section (C.4)
        _buildFavoritesSection(context, ref, isDark),
        const SizedBox(height: 20),

        // "Your week" Streak Tracker Card (C.6)
        _buildYourWeekCard(weekLogs, maxStreak, isDark),
        const SizedBox(height: 28),

        // "Your practices" Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your practices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC27351),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onPressed: () => context.push('/create-goal'),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text(
                'New practice',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Dynamic Practice Cards
        if (goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No goals set yet. Choose a practice template below.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          )
        else
          ...goals.asMap().entries.map((entry) {
            final idx = entry.key;
            final goal = entry.value;
            final colors = [
              const Color(0xFFB96847), // Terracotta
              const Color(0xFF4D7C68), // Sage Green
              const Color(0xFFC28B45), // Ochre Gold
            ];
            final icons = [
              Icons.auto_awesome_rounded,
              Icons.local_fire_department_rounded,
              Icons.menu_book_rounded,
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: _buildDynamicPracticeCard(
                context,
                ref,
                goal: goal,
                color: colors[idx % colors.length],
                icon: icons[idx % icons.length],
                isDark: isDark,
                userId: userId,
              ),
            );
          }),

        const SizedBox(height: 16),

        // "Ibadah & Calculators" Section (C.3, A.1, A.2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ibadah Toolkit & Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/toolkit'),
              child: const Text('Open Toolkit', style: TextStyle(color: Color(0xFFC27351), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildQuickAccessRow(context, ref, isDark),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Recitation of the Day (C.7)
  Widget _buildRecitationOfTheDay(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final recitations = {
      1: {'id': 'surah_yasin', 'title': 'Surah Yasin', 'reason': 'Recommended for Monday Barakah', 'arabic': 'یس ۝١ وَالْقُرْآنِ الْحَكِيمِ'},
      2: {'id': 'dua_tawassul', 'title': 'Dua-e-Tawassul', 'reason': 'Traditional Tuesday Night Supplication', 'arabic': 'يَا وَجِيهًا عِنْدَ اللَّهِ اشْفَعْ لَنَا عِنْدَ اللَّهِ'},
      3: {'id': 'ziyarat_waritha', 'title': 'Ziyarat Waritha', 'reason': 'Wednesday Remembrance of Prophets & Ahlulbayt', 'arabic': 'السَّلَامُ عَلَيْكَ يَا وَارِثَ آدَمَ صَفْوَةِ اللَّهِ'},
      4: {'id': 'dua_kumayl', 'title': 'Dua Kumayl', 'reason': 'Blessed Thursday Night Supplication of Imam Ali (a.s.)', 'arabic': 'اَللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ'},
      5: {'id': 'ziyarat_ale_yasin', 'title': 'Ziyarat Ale-Yasin', 'reason': 'Sacred Friday Salutation to Imam al-Mahdi (a.t.f.s.)', 'arabic': 'سَلَامٌ عَلَى آلِ يس، السَّلَامُ عَلَيْكَ يَا دَاعِيَ اللَّهِ'},
      6: {'id': 'surah_fatiha', 'title': 'Surah Al-Fatiha', 'reason': 'Saturday Spiritual Reflection', 'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝١ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ'},
      7: {'id': 'ziyarat_ashura', 'title': 'Ziyarat Ashura', 'reason': 'Sunday Salutations to the Master of Martyrs (a.s.)', 'arabic': 'السَّلَامُ عَلَيْكَ يَا أَبَا عَبْدِ اللَّهِ'},
    };

    final rec = recitations[now.weekday] ?? recitations[4]!;
    final contentId = rec['id']!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC27351).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_stories_rounded, color: Color(0xFFC27351), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'RECITATION OF THE DAY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFFC27351),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D7C68).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Today', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4D7C68))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec['title']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rec['reason']!,
            style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121820) : const Color(0xFFF7F4EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              rec['arabic']!,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC28B45),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC27351),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => context.push('/reader/$contentId'),
              child: const Text('Open Recitation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }

  /// Hadith of the Day (C.8)
  Widget _buildHadithOfTheDay(bool isDark) {
    final hadiths = [
      {
        'text': 'The most beloved of deeds to Allah are those that are consistent, even if they are small.',
        'speaker': 'Holy Prophet Muhammad (s.a.w.)',
        'ref': 'Al-Kafi, Vol. 2',
      },
      {
        'text': 'A small deed done with Taqwa (God-consciousness) is never small; how can that which is accepted be small?',
        'speaker': 'Imam Ali (a.s.)',
        'ref': 'Nahj al-Balagha, Saying 95',
      },
      {
        'text': 'Charity wards off calamity and is the best medicine for ailments.',
        'speaker': 'Imam Ja\'far al-Sadiq (a.s.)',
        'ref': 'Bihar al-Anwar, Vol. 93',
      },
      {
        'text': 'He who is mindful of praying for the Faraj of our Qa\'im, Allah fulfills his own affairs.',
        'speaker': 'Imam al-Hasan al-Askari (a.s.)',
        'ref': 'Kamal al-Din',
      },
      {
        'text': 'The best worship is the awaiting of relief (Intizar al-Faraj) accompanied by righteous deeds.',
        'speaker': 'Holy Prophet Muhammad (s.a.w.)',
        'ref': 'Tuhaf al-Uqul',
      },
      {
        'text': 'Patience in relation to faith is like the head in relation to the body: when the head goes, the body goes.',
        'speaker': 'Imam Ali (a.s.)',
        'ref': 'Nahj al-Balagha, Saying 82',
      },
      {
        'text': 'Acquire knowledge, for it is a guide on the path to Paradise and a companion in times of solitude.',
        'speaker': 'Imam Ali al-Reza (a.s.)',
        'ref': 'Uyun Akhbar al-Reza',
      },
    ];

    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final hadith = hadiths[dayOfYear % hadiths.length];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'HADITH OF THE DAY',
                style: TextStyle(
                  color: Color(0xFFE8C86A),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.format_quote_rounded, color: Color(0xFFE8C86A), size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${hadith['text']}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hadith['speaker']!,
                style: const TextStyle(
                  color: Color(0xFFE8C86A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              Text(
                hadith['ref']!,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Favorites Section Carousel (C.4)
  Widget _buildFavoritesSection(BuildContext context, WidgetRef ref, bool isDark) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: ReaderPreferencesService.favoritesNotifier,
      builder: (context, favIds, _) {
        if (favIds.isEmpty) return const SizedBox.shrink();

        final allContentAsync = ref.watch(allContentStreamProvider);
        final allContent = allContentAsync.value ?? [];
        final favItems = allContent.where((c) => favIds.contains(c.contentId)).toList();

        if (favItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Your Favorites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                  ],
                ),
                Text('${favItems.length} starred', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: favItems.length,
                itemBuilder: (context, idx) {
                  final item = favItems[idx];
                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/reader/${item.contentId}'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF17202C) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.type.toUpperCase(),
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFFB8860B)),
                              ),
                            ),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Quick Access row for Ibadah Toolkit, Khums, and Sadqa (C.3, A.1, A.2)
  Widget _buildQuickAccessRow(BuildContext context, WidgetRef ref, bool isDark) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

    final tools = [
      {
        'title': 'Ibadah Toolkit',
        'subtitle': 'Qibla, Tasbeeh & Times',
        'icon': Icons.explore_rounded,
        'color': const Color(0xFF1B2A3D),
        'route': '/toolkit',
      },
      {
        'title': 'Khums Calc',
        'subtitle': 'Annual 20% Net Surplus',
        'icon': Icons.calculate_rounded,
        'color': const Color(0xFFC27351),
        'route': '/khums',
      },
      {
        'title': 'Daily Sadqa',
        'subtitle': 'Charity Log & Reminders',
        'icon': Icons.volunteer_activism_rounded,
        'color': const Color(0xFF5E8D77),
        'route': '/sadqa',
      },
    ];

    return Row(
      children: tools.map((tool) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.push(tool['route'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: (tool['color'] as Color).withValues(alpha: 0.15),
                      child: Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tool['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool['subtitle'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Top Greeting Header with respectful phrasing (C.9)
  Widget _buildGreetingHeader(String name, String initial, bool isDark) {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]}';

    final greetings = [
      'Salamun Alaykum',
      'Peace be with you',
      'Welcome back',
      'Bismillah',
    ];
    final greetingPrefix = greetings[(now.day + now.weekday) % greetings.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    const SizedBox(width: 5),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$greetingPrefix,',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                  ),
                ),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC27351),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFC27351),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Deep Navy "YOUR DAILY NIYYAH" Hero Card
  Widget _buildDailyNiyyahCard({
    required int totalCompleted,
    required int totalPlanned,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D), // Deep Navy Slate
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sparkles tag & Hijri date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFD4AF37)),
                  SizedBox(width: 6),
                  Text(
                    'YOUR DAILY NIYYAH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Text(
                '17 Safar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Headline
          const Text(
            'Begin with\na quiet heart.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Small, sincere practices become a path.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Stats & Circular Gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY\'S PRACTICE',
                    style: TextStyle(
                      color: Color(0xFFC27351),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCompleted of $totalPlanned recitations',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Circular Percentage Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC27351),
                    width: 2.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Your week" Streak Card with 7 Days (Monday to Sunday)
  Widget _buildYourWeekCard(
    List<StreakLogModel> weekLogs,
    int maxStreak,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 18, color: Color(0xFFC27351)),
                const SizedBox(width: 4),
                Text(
                  '$maxStreak day streak',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC27351),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final dayDate = monday.add(Duration(days: index));
              final isToday = dayIndex == currentWeekday;

              final dayDateStr =
                  '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';

              // Check if any log in weekLogs has status == 'done' on this date (C.6 strictly check actual completion)
              final hasCompleted = weekLogs.any(
                (log) => log.date == dayDateStr && log.status == 'done',
              );

              final isDone = hasCompleted;

              return _buildDayCircle(
                dayLabels[index],
                isDone,
                isToday: isToday,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCircle(String day, bool isDone, {bool isToday = false}) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF5E8D77) // Sage Green
                : (isToday ? Colors.transparent : Colors.grey.withValues(alpha: 0.1)),
            border: isToday
                ? Border.all(color: const Color(0xFFC27351), width: 2)
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : (isToday
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFC27351),
                        ),
                      )
                    : null),
          ),
        ),
      ],
    );
  }

  /// Dynamic Practice Card wired to GoalModel and recitation action
  Widget _buildDynamicPracticeCard(
    BuildContext context,
    WidgetRef ref, {
    required GoalModel goal,
    required Color color,
    required IconData icon,
    required bool isDark,
    required String userId,
  }) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

    final completedCount = (goal.progressToday * goal.items.length).round();
    final totalCount = goal.items.length;
    final percentageStr = '${(goal.progressToday * 100).round()}%';
    final primaryContentId = goal.items.isNotEmpty ? goal.items.first : 'dua_ahad';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable card header navigates to reader
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(
                '/reader/$primaryContentId',
                extra: {'goalId': goal.goalId},
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goal.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  percentageStr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Progress Bar with Count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.progressToday,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Row: "Mark as recited" and "Read"
          Row(
            children: [
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () async {
                    // Quick record recitation
                    final repo = ref.read(contentRepositoryProvider);
                    await repo.recordItemRecited(
                      userId: userId,
                      goalId: goal.goalId,
                      contentId: primaryContentId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF4D7C68),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          content: Text(
                            'Recitation recorded for "${goal.title}"!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Mark as recited',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Open in Reader button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () {
                  context.push(
                    '/reader/$primaryContentId',
                    extra: {'goalId': goal.goalId},
                  );
                },
                child: const Text('Read', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// App Navigation Drawer for account-level items (Priority 6)
  Widget _buildAppDrawer(BuildContext context, WidgetRef ref, UserModel user, bool isDark) {
    final drawerBg = isDark ? const Color(0xFF121B27) : const Color(0xFFFAF8F5);
    final textCol = isDark ? Colors.white : const Color(0xFF1B2A3D);
    final isScholar = user.role == 'scholar';

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // Top User Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF182230) : const Color(0xFFEDE8E1),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFC27351),
                    child: Text(
                      (user.name.isNotEmpty ? user.name[0] : 'M').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : 'Muntazir Seeker',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textCol,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Marja: ${user.marja.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC27351),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: Color(0xFFC27351)),
                    title: Text('Profile & Settings', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Language, Marja, Font size & Theme', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFC27351)),
                    title: Text('Daily Practices & Streaks', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFC27351)),
                    title: Text('Ask Muntazir AI', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_rounded, color: Color(0xFFC27351)),
                    title: Text('Holy Quran & Library', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(3);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_rounded, color: Color(0xFFC27351)),
                    title: Text('Community & Venues', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(4);
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    leading: const Icon(Icons.explore_rounded, color: Color(0xFF1B2A3D)),
                    title: Text('Ibadah Toolkit', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Qibla, Tasbeeh, Prayer Times & Shia Calendar', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/toolkit');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.calculate_rounded, color: Color(0xFFC27351)),
                    title: Text('Khums Calculator', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Annual 20% Net Surplus breakdown & reminder', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/khums');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.volunteer_activism_rounded, color: Color(0xFF5E8D77)),
                    title: Text('Daily Sadqa', style: TextStyle(color: textCol, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Running charity log & daily reminders', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/sadqa');
                    },
                  ),
                  if (isScholar) ...[
                    const Divider(height: 20),
                    ListTile(
                      leading: const Icon(Icons.verified_rounded, color: Color(0xFFD4AF37)),
                      title: Text('Scholar Dashboard', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Answer submitted community fiqh questions', style: TextStyle(fontSize: 11)),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/scholar-dashboard');
                      },
                    ),
                  ],
                  const Divider(height: 24),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Colors.grey),
                    title: Text('About Muntazir', style: TextStyle(color: textCol, fontWeight: FontWeight.w500)),
                    subtitle: const Text('Version 1.0.0 • Shia Islamic AI Companion', style: TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'Muntazir',
                        applicationVersion: '1.0.0',
                        applicationIcon: const CircleAvatar(
                          backgroundColor: Color(0xFF1B2A3D),
                          child: Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                        ),
                        children: const [
                          Text('Dedicated Shia Islamic companion for spiritual growth, authentic Fiqh guidance according to Grand Ayatollah Sistani and Ayatollah Khamenei, Holy Quran recitation, Duas, prayer reminders, and community mosque locator.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // Sign out button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref.read(userServiceProvider).signOut();
                    if (context.mounted) {
                      context.go('/onboarding');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
