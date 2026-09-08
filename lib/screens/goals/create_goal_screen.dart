import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/goal_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/ai_service.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Custom Goal form state
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedContentIds = {};
  String _searchQuery = '';
  bool _isSaving = false;

  // AI Goal Matcher state
  final _intentionController = TextEditingController();
  bool _isAiGenerating = false;
  Map<String, dynamic>? _aiRecommendation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _intentionController.dispose();
    super.dispose();
  }

  Future<void> _generateAiPractice() async {
    final text = _intentionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your intention first.')),
      );
      return;
    }

    setState(() {
      _isAiGenerating = true;
      _aiRecommendation = null;
    });

    try {
      final res = await AiService.matchIntentionToGoals(text);
      if (mounted) {
        setState(() {
          _aiRecommendation = res;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI matching note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAiGenerating = false);
      }
    }
  }

  Future<void> _saveGoal({
    required String title,
    required String description,
    required List<String> items,
    required String createdVia,
  }) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one Dua, Ziyarat, or Surah.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authUser = ref.read(authStateProvider).value;
      final userId = authUser?.uid ?? 'guest_user';
      final repo = ref.read(contentRepositoryProvider);

      final goalId = 'goal_${DateTime.now().millisecondsSinceEpoch}';
      final newGoal = GoalModel(
        goalId: goalId,
        userId: userId,
        title: title,
        description: description,
        items: items,
        streakCount: 0,
        progressToday: 0.0,
        createdVia: createdVia,
        createdAt: DateTime.now(),
      );

      await repo.createGoal(newGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4D7C68), // Sage Green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Spiritual practice "$title" added successfully!'),
                ),
              ],
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving practice: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Spiritual Practice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC27351),
          indicatorWeight: 3,
          labelColor: const Color(0xFFC27351),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Templates'),
            Tab(text: 'AI Tailored'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplatesTab(isDark),
          _buildAiTailoredTab(isDark),
          _buildCustomPracticeTab(isDark),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab(bool isDark) {
    final templates = [
      {
        'title': 'Imam Mahdi\'s Servant',
        'desc': 'A quiet daily practice for presence and covenant renewal.',
        'items': ['dua_ahad', 'ziyarat_ale_yasin'],
        'color': const Color(0xFFB96847),
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'title': '40 Days of Dua-e-Ahad',
        'desc': 'Begin every morning reciting the covenant with the 12th Imam.',
        'items': ['dua_ahad'],
        'color': const Color(0xFF4D7C68),
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'title': 'Arbaeen Journey',
        'desc': 'Daily remembrance, reflection, and salutations to the martyrs of Karbala.',
        'items': ['ziyarat_ashura', 'ziyarat_waritha'],
        'color': const Color(0xFFC28B45),
        'icon': Icons.menu_book_rounded,
      },
      {
        'title': 'Thursday Night Vigil',
        'desc': 'Supplicate with the words of Ameerul Momineen Ali (a.s.) taught to Kumayl.',
        'items': ['dua_kumayl'],
        'color': const Color(0xFF5E8D77),
        'icon': Icons.nightlight_round,
      },
      {
        'title': 'Tuesday Intercession (Tawassul)',
        'desc': 'Seek closeness to Allah through the intercession of the 14 Infallibles.',
        'items': ['dua_tawassul'],
        'color': const Color(0xFF9E5B3D),
        'icon': Icons.volunteer_activism_rounded,
      },
      {
        'title': 'Daily Quran Light',
        'desc': 'Recite Surah Al-Fatiha and Surah Yasin daily for spiritual blessings.',
        'items': ['surah_al_fatiha', 'surah_yasin'],
        'color': const Color(0xFF386B5A),
        'icon': Icons.menu_book_rounded,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        final title = t['title'] as String;
        final desc = t['desc'] as String;
        final items = (t['items'] as List).cast<String>();
        final color = t['color'] as Color;
        final icon = t['icon'] as IconData;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${items.length} recitations daily',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving
                      ? null
                      : () => _saveGoal(
                            title: title,
                            description: desc,
                            items: items,
                            createdVia: 'template',
                          ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Adopt This Practice',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiTailoredTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A3D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'GEMINI SPIRITUAL COMPANION',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Tell us what your heart seeks.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Our Shia spiritual AI will match your state with authentic Duas, Ziyarat, and Quranic verses.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Your spiritual intention or feeling:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _intentionController,
          maxLines: 3,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          decoration: InputDecoration(
            hintText: 'e.g. I am feeling anxious and want closeness to Imam Hussain (a.s.), or I want to renew my covenant with Imam Mahdi...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC27351),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isAiGenerating ? null : _generateAiPractice,
            child: _isAiGenerating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Recommend Practice', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // AI Recommendation Result Card
        if (_aiRecommendation != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFC27351).withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC27351).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Color(0xFFC27351), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _aiRecommendation!['title'] as String? ?? 'Recommended Practice',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _aiRecommendation!['description'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Spiritual Advice Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, color: Color(0xFFC28B45), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aiRecommendation!['advice'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D7C68), // Sage Green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            final title = _aiRecommendation!['title'] as String;
                            final desc = _aiRecommendation!['description'] as String;
                            final items = List<String>.from(
                              _aiRecommendation!['matched_items'] ?? ['dua_ahad'],
                            );
                            _saveGoal(
                              title: title,
                              description: desc,
                              items: items,
                              createdVia: 'ai',
                            );
                          },
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Adopt This AI Practice',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCustomPracticeTab(bool isDark) {
    final allContentAsync = ref.watch(allContentStreamProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      children: [
        Text(
          'Name your practice',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          decoration: InputDecoration(
            hintText: 'e.g. My Morning Recitations',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
            filled: true,
            fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Spiritual intention / note',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          decoration: InputDecoration(
            hintText: 'e.g. For peace of heart and remembrance of Ahlulbayt',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
            filled: true,
            fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Texts (${_selectedContentIds.length} chosen)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC27351)),
            hintText: 'Search Duas, Ziyarat, Surahs...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
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
        const SizedBox(height: 14),

        // Available items list
        allContentAsync.when(
          data: (items) {
            final filtered = items.where((item) {
              if (_searchQuery.isEmpty) return true;
              final text = '${item.title} ${item.type} ${item.tags.join(" ")}'.toLowerCase();
              return text.contains(_searchQuery);
            }).toList();

            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No matching content found.',
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              );
            }

            return Column(
              children: filtered.map((item) {
                final isSelected = _selectedContentIds.contains(item.contentId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17202C) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC27351)
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    activeColor: const Color(0xFFC27351),
                    value: isSelected,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedContentIds.add(item.contentId);
                        } else {
                          _selectedContentIds.remove(item.contentId);
                        }
                      });
                    },
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    subtitle: Text(
                      item.type.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC27351),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFC27351)),
          ),
          error: (err, _) => Text('Error loading library: $err'),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC27351),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isSaving
                ? null
                : () {
                    final title = _titleController.text.trim().isNotEmpty
                        ? _titleController.text.trim()
                        : 'Custom Spiritual Practice';
                    final desc = _descController.text.trim().isNotEmpty
                        ? _descController.text.trim()
                        : 'Personal daily recitations';
                    _saveGoal(
                      title: title,
                      description: desc,
                      items: _selectedContentIds.toList(),
                      createdVia: 'manual',
                    );
                  },
            child: _isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Practice',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
