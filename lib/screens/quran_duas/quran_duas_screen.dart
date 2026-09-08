import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/content_model.dart';
import '../../providers/content_provider.dart';
import '../../services/quran_service.dart';
import 'qadha_tracker_widget.dart';

class QuranDuasScreen extends ConsumerStatefulWidget {
  const QuranDuasScreen({super.key});

  @override
  ConsumerState<QuranDuasScreen> createState() => _QuranDuasScreenState();
}

class _QuranDuasScreenState extends ConsumerState<QuranDuasScreen> {
  String _quranSearch = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
          elevation: 0,
          title: Text(
            'Library',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: const Color(0xFFC27351), // Terracotta
            indicatorWeight: 3,
            labelColor: const Color(0xFFC27351),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Holy Quran'),
              Tab(text: 'Duas'),
              Tab(text: 'Ziyarat'),
              Tab(text: 'Prayer Check-In'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQuranTab(isDark),
            _buildContentList('dua', isDark),
            _buildContentList('ziyarat', isDark),
            const QadhaTrackerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranTab(bool isDark) {
    final filteredSurahs = QuranService.allSurahs.where((s) {
      if (_quranSearch.isEmpty) return true;
      final q = _quranSearch.toLowerCase();
      return s.englishName.toLowerCase().contains(q) ||
          s.englishNameTranslation.toLowerCase().contains(q) ||
          s.nameArabic.contains(q) ||
          s.number.toString() == q;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
          child: TextField(
            onChanged: (val) => setState(() => _quranSearch = val),
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC27351)),
              hintText: 'Search Surah by name or number (e.g. Yasin, 36)...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 13,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            itemCount: filteredSurahs.length,
            itemBuilder: (context, index) {
              final surah = filteredSurahs[index];
              return _buildSurahCard(surah, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahCard(SurahMeta surah, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (surah.number == 1) {
              context.push('/reader/surah_fatiha');
            } else if (surah.number == 36) {
              context.push('/reader/surah_yasin');
            } else {
              context.push('/reader/surah_${surah.number}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Surah Number Diamond/Circle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC27351).withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFFC27351),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // English Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.englishName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.englishNameTranslation} • ${surah.numberOfAyahs} verses',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Name
                Text(
                  surah.nameArabic,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC28B45), // Ochre Gold
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList(String type, bool isDark) {
    final contentAsync = ref.watch(contentByTypeStreamProvider(type));

    return contentAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No items found in this section.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildContentCard(item, isDark);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFC27351)),
      ),
      error: (err, _) => Center(
        child: Text('Error loading content: $err'),
      ),
    );
  }

  Widget _buildContentCard(ContentModel item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/reader/${item.contentId}');
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC27351).withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFC27351),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.translationEn,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.3,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFFC27351),
                    ),
                  ],
                ),
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
