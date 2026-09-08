import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/companion_models.dart';
import '../../providers/user_provider.dart';
import '../../services/ai_service.dart';

class AskScreen extends ConsumerStatefulWidget {
  const AskScreen({super.key});

  @override
  ConsumerState<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends ConsumerState<AskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Chat state
  final _chatInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedMarja = 'sistani';
  bool _isAiResponding = false;
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text':
          'Salamun alaykum! I am Muntazir AI, your spiritual companion. You can ask me regarding Shia supplications, Quranic reflections, or general Fiqh according to Ayatollah Sistani or Ayatollah Khamenei.',
    }
  ];

  // Ask Scholar state
  final _scholarQuestionController = TextEditingController();
  bool _isSubmittingScholar = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatInputController.dispose();
    _scholarQuestionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendChatMessage([String? customText]) async {
    final query = customText ?? _chatInputController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': query});
      _isAiResponding = true;
      if (customText == null) {
        _chatInputController.clear();
      }
    });

    _scrollToBottom();

    try {
      final response = await AiService.askSpiritualQuestion(
        question: query,
        marja: _selectedMarja == 'sistani' ? 'Sistani' : 'Khamenei',
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'text': response});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text':
                'Unable to get an answer right now. Please consult official sources at sistani.org or leader.ir.',
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAiResponding = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitScholarQuestion() async {
    final text = _scholarQuestionController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your question.')),
      );
      return;
    }

    setState(() => _isSubmittingScholar = true);

    try {
      final authUser = ref.read(authStateProvider).value;
      final userId = authUser?.uid ?? 'guest_user';
      final questionId = 'q_${DateTime.now().millisecondsSinceEpoch}';

      final question = QuestionModel(
        questionId: questionId,
        userId: userId,
        text: text,
        status: 'pending_scholar',
        marjaComparison: [
          {'marja': _selectedMarja}
        ],
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .set(question.toMap());

      if (mounted) {
        _scholarQuestionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4D7C68),
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Question sent to Shia scholars successfully!'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingScholar = false);
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
        title: Text(
          'Ask',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC27351),
          indicatorWeight: 3,
          labelColor: const Color(0xFFC27351),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Muntazir AI'),
            Tab(text: 'Ask a Scholar'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Religious Disclaimer Banner (Required by prompt)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF26200A) : const Color(0xFFFFF9E6),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFB8860B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Informational only. Please confirm with your Marja\'s office for binding fatwas.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFE8C86A) : const Color(0xFF7A5900),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAiChatTab(isDark),
                _buildAskScholarTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiChatTab(bool isDark) {
    return Column(
      children: [
        // Marja Selection Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isDark ? const Color(0xFF141C26) : const Color(0xFFF2ECE1),
          child: Row(
            children: [
              Text(
                'Marja:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Ayatollah Sistani', style: TextStyle(fontSize: 11)),
                selected: _selectedMarja == 'sistani',
                selectedColor: const Color(0xFFC27351),
                labelStyle: TextStyle(
                  color: _selectedMarja == 'sistani' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _selectedMarja = 'sistani'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Ayatollah Khamenei', style: TextStyle(fontSize: 11)),
                selected: _selectedMarja == 'khamenei',
                selectedColor: const Color(0xFFC27351),
                labelStyle: TextStyle(
                  color: _selectedMarja == 'khamenei' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _selectedMarja = 'khamenei'),
              ),
            ],
          ),
        ),

        // Quick Suggestion Chips
        if (_messages.length <= 1)
          Container(
            height: 42,
            margin: const EdgeInsets.only(top: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildPromptChip('Sajdah as-Sahw rules', isDark),
                _buildPromptChip('Spiritual virtues of Dua-e-Ahad', isDark),
                _buildPromptChip('Joining Friday prayers (Jummah)', isDark),
                _buildPromptChip('Meaning of Ziyarat Ale-Yasin', isDark),
              ],
            ),
          ),

        // Chat Messages Stream
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFFC27351) // Terracotta
                        : (isDark ? const Color(0xFF17202C) : Colors.white),
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(18),
                      bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                    ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF1B2A3D)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_isAiResponding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC27351)),
                ),
                const SizedBox(width: 10),
                Text(
                  'Muntazir AI is reflecting...',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ],
            ),
          ),

        // Chat Input Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatInputController,
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
                    decoration: InputDecoration(
                      hintText: 'Ask a Fiqh or spiritual question...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 13.5,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFC27351),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                    onPressed: _isAiResponding ? null : () => _sendChatMessage(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptChip(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
          ),
        ),
        onPressed: () => _sendChatMessage(label),
      ),
    );
  }

  Widget _buildAskScholarTab(bool isDark) {
    final authUser = ref.watch(authStateProvider).value;
    final userId = authUser?.uid ?? 'guest_user';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC28B45).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school_rounded, color: Color(0xFFC28B45), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Direct Scholar Inquiries',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Submit complex personal questions directly to certified Shia scholars. Replies appear below once verified.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _scholarQuestionController,
                maxLines: 4,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
                decoration: InputDecoration(
                  hintText: 'Type your question clearly with relevant context...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 13),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
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
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC27351),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSubmittingScholar ? null : _submitScholarQuestion,
                  child: _isSubmittingScholar
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Question to Scholar',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'My Submitted Inquiries',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 12),

        // Stream of user questions from Firestore
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('questions')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: Text(
                  'No questions submitted yet.',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              );
            }

            return Column(
              children: docs.map((doc) {
                final q = QuestionModel.fromMap(doc.data(), doc.id);
                final isAnswered = q.status == 'answered';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17202C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAnswered
                                  ? const Color(0xFF4D7C68).withValues(alpha: 0.15)
                                  : const Color(0xFFC28B45).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isAnswered ? 'Answered by Scholar ✓' : 'Pending Review',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAnswered ? const Color(0xFF4D7C68) : const Color(0xFFC28B45),
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              final marjaName = q.marjaComparison.isNotEmpty
                                  ? (q.marjaComparison.first['marja'] ?? 'SISTANI')
                                  : 'SISTANI';
                              return Text(
                                marjaName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        q.text,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                        ),
                      ),
                      if (isAnswered && q.scholarAnswer != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scholar Reply (${q.answeredBy ?? 'Sheikh'}):',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC27351),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.scholarAnswer!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
