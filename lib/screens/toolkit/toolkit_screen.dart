import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/prayer_times_service.dart';

class ToolkitScreen extends ConsumerStatefulWidget {
  const ToolkitScreen({super.key});

  @override
  ConsumerState<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends ConsumerState<ToolkitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tasbeeh State
  int _tasbeehCount = 0;
  int _tasbeehStage = 0; // 0: Allahu Akbar (34), 1: Alhamdulillah (33), 2: SubhanAllah (33)
  final List<String> _tasbeehTitles = ['Allahu Akbar', 'Alhamdulillah', 'SubhanAllah'];
  final List<int> _tasbeehLimits = [34, 33, 33];

  // Prayer times state
  PrayerTimesModel? _prayerTimes;
  bool _isLoadingPrayers = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await PrayerTimesService.getShiaPrayerTimes();
      if (mounted) {
        setState(() {
          _prayerTimes = times;
          _isLoadingPrayers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _prayerTimes = PrayerTimesModel.defaultNajaf();
          _isLoadingPrayers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _incrementTasbeeh() {
    HapticFeedback.lightImpact();
    setState(() {
      _tasbeehCount++;
      if (_tasbeehCount >= _tasbeehLimits[_tasbeehStage]) {
        HapticFeedback.mediumImpact();
        _tasbeehCount = 0;
        _tasbeehStage = (_tasbeehStage + 1) % 3;
      }
    });
  }

  void _resetTasbeeh() {
    HapticFeedback.selectionClick();
    setState(() {
      _tasbeehCount = 0;
      _tasbeehStage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Ibadah Toolkit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFC27351),
          indicatorWeight: 3,
          labelColor: const Color(0xFFC27351),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: const [
            Tab(icon: Icon(Icons.explore_rounded, size: 20), text: 'Qibla'),
            Tab(icon: Icon(Icons.fingerprint_rounded, size: 20), text: 'Tasbeeh'),
            Tab(icon: Icon(Icons.access_time_filled_rounded, size: 20), text: 'Namaz Times'),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 20), text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQiblaTab(isDark),
          _buildTasbeehTab(isDark),
          _buildNamazTab(isDark),
          _buildCalendarTab(isDark),
        ],
      ),
    );
  }

  // --- 1. Qibla Finder Tab ---
  Widget _buildQiblaTab(bool isDark) {
    // Standard Qibla bearing calculation from Indian subcontinent / Middle East (~272° W-NW)
    const double qiblaAngle = 272.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFFC27351)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kaaba Direction: ${qiblaAngle.toInt()}° WNW',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Holy Kaaba, Makkah al-Mukarramah',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Compass Dial Visualization
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Dial Ring
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF17202C) : Colors.white,
                      border: Border.all(color: const Color(0xFFC27351), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC27351).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Cardinal Indicators
                  const Positioned(top: 14, child: Text('N', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 16))),
                  const Positioned(bottom: 14, child: Text('S', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const Positioned(right: 14, child: Text('E', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  const Positioned(left: 14, child: Text('W', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),

                  // Qibla Pointer Needle
                  Transform.rotate(
                    angle: (qiblaAngle - 90) * (math.pi / 180),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4D7C68), Color(0xFFD4AF37)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC27351),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 60,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),

                  // Center Kaaba Icon Badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B2A3D),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mosque_rounded, color: Color(0xFFE8C86A), size: 22),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Align your device horizontally and face towards the green needle pointer for the Qibla.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Tasbeeh Counter Tab ---
  Widget _buildTasbeehTab(bool isDark) {
    final title = _tasbeehTitles[_tasbeehStage];
    final limit = _tasbeehLimits[_tasbeehStage];
    final progress = _tasbeehCount / limit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Text(
            'Tasbeeh of Sayyida Fatima al-Zahra (s.a.)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE8C86A) : const Color(0xFF8C6B1F),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Step ${_tasbeehStage + 1} of 3 ($limit times)',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
          ),
          const Spacer(),

          // Big Interactive Tap Button
          InkWell(
            onTap: _incrementTasbeeh,
            borderRadius: BorderRadius.circular(120),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFC27351), Color(0xFF9E4B2B)],
                  center: Alignment(-0.2, -0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC27351).withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_tasbeehCount',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/ $limit',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4D7C68)),
            ),
          ),
          const SizedBox(height: 20),

          // Reset Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _resetTasbeeh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reset Counter', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- 3. Namaz Timings Tab ---
  Widget _buildNamazTab(bool isDark) {
    if (_isLoadingPrayers) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
    }

    final p = _prayerTimes ?? PrayerTimesModel.defaultNajaf();
    final prayers = [
      {'name': 'Fajr', 'time': p.fajr, 'icon': Icons.brightness_5_rounded},
      {'name': 'Sunrise', 'time': p.sunrise, 'icon': Icons.wb_sunny_rounded},
      {'name': 'Dhuhr', 'time': p.dhuhr, 'icon': Icons.wb_sunny_outlined},
      {'name': 'Asr', 'time': p.asr, 'icon': Icons.wb_cloudy_rounded},
      {'name': 'Sunset', 'time': p.sunset, 'icon': Icons.nightlight_round},
      {'name': 'Maghrib (Shia)', 'time': p.maghrib, 'icon': Icons.nights_stay_rounded},
      {'name': 'Isha', 'time': p.isha, 'icon': Icons.bedtime_rounded},
      {'name': 'Midnight (Shia)', 'time': p.midnight, 'icon': Icons.dark_mode_rounded},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A3D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Shia Ithna-Ashari Calculation',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Institute of Geophysics, University of Tehran / Leva Research Institute Qum',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...prayers.map((item) {
          final isHighlighted = item['name'] == 'Maghrib (Shia)' || item['name'] == 'Dhuhr' || item['name'] == 'Fajr';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHighlighted ? const Color(0xFFC27351) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                Icon(item['icon'] as IconData, color: isHighlighted ? const Color(0xFFC27351) : Colors.grey[500]),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item['name'] as String,
                    style: TextStyle(
                      fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  item['time'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isHighlighted ? const Color(0xFFC27351) : (isDark ? Colors.white : const Color(0xFF1B2A3D)),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- 4. Islamic Calendar Tab ---
  Widget _buildCalendarTab(bool isDark) {
    final keyDates = [
      {'title': 'Arbaeen of Imam Hussain (a.s.)', 'date': '20 Safar', 'type': 'Shahadat'},
      {'title': 'Shahadat of Prophet Muhammad (s.a.w.) & Imam Hasan (a.s.)', 'date': '28 Safar', 'type': 'Shahadat'},
      {'title': 'Eid al-Zahra / Wiladat 12th Imam Coronation', 'date': '9 Rabi al-Awwal', 'type': 'Wiladat'},
      {'title': 'Wiladat of Prophet Muhammad (s.a.w.) & Imam Sadiq (a.s.)', 'date': '17 Rabi al-Awwal', 'type': 'Wiladat'},
      {'title': 'Shahadat of Lady Fatima Zahra (s.a.) (Ayyam-e-Fatimiya)', 'date': '3 Jumada al-Thani', 'type': 'Shahadat'},
      {'title': 'Wiladat of Imam Ali ibn Abi Talib (a.s.)', 'date': '13 Rajab', 'type': 'Wiladat'},
      {'title': 'Mab\'ath of the Holy Prophet (s.a.w.)', 'date': '27 Rajab', 'type': 'Wiladat'},
      {'title': 'Wiladat of Imam Hussain (a.s.)', 'date': '3 Sha\'ban', 'type': 'Wiladat'},
      {'title': 'Wiladat of Imam al-Mahdi (a.t.f.s.)', 'date': '15 Sha\'ban', 'type': 'Wiladat'},
      {'title': 'Nuzool-e-Quran / Laylat al-Qadr', 'date': '19, 21, 23 Ramadan', 'type': 'Ibadah'},
      {'title': 'Shahadat of Imam Ali (a.s.)', 'date': '21 Ramadan', 'type': 'Shahadat'},
      {'title': 'Eid al-Fitr', 'date': '1 Shawwal', 'type': 'Eid'},
      {'title': 'Eid al-Ghadeer', 'date': '18 Dhu al-Hijjah', 'type': 'Eid'},
      {'title': 'Day of Ashura (Karbala)', 'date': '10 Muharram', 'type': 'Shahadat'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2A3D), Color(0xFF111D2B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('HIJRI SACRED OCCASIONS', style: TextStyle(color: Color(0xFFE8C86A), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              SizedBox(height: 6),
              Text('Ahlulbayt (a.s.) Wiladat & Shahadat Anniversaries', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...keyDates.map((d) {
          final isShahadat = d['type'] == 'Shahadat';
          final badgeColor = isShahadat ? const Color(0xFFB96847) : const Color(0xFF4D7C68);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    d['date']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: badgeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    d['title']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
