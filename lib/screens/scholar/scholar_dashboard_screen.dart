import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/companion_models.dart';
import '../../providers/user_provider.dart';

class ScholarDashboardScreen extends ConsumerStatefulWidget {
  const ScholarDashboardScreen({super.key});

  @override
  ConsumerState<ScholarDashboardScreen> createState() => _ScholarDashboardScreenState();
}

class _ScholarDashboardScreenState extends ConsumerState<ScholarDashboardScreen> {
  final _answerControllers = <String, TextEditingController>{};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final ctrl in _answerControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submitAnswer(QuestionModel question, String scholarName) async {
    final ctrl = _answerControllers[question.questionId];
    final answerText = ctrl?.text.trim() ?? '';

    if (answerText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write an answer before submitting.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(question.questionId)
          .update({
        'status': 'answered',
        'scholar_answer': answerText,
        'answered_by': scholarName.isNotEmpty ? scholarName : 'Sheikh Ali Raza',
        'answered_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ctrl?.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF4D7C68),
            content: Text('Answer published to user successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error answering question: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scholarName = user?.name ?? 'Sheikh';

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Scholar Question Portal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('questions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mark_chat_read_rounded, size: 52, color: Color(0xFF4D7C68)),
                    const SizedBox(height: 16),
                    Text(
                      'No questions pending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'All community inquiries have been answered.',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final q = QuestionModel.fromMap(docs[index].data(), docs[index].id);
              final isPending = q.status != 'answered';
              final ctrl = _answerControllers.putIfAbsent(
                q.questionId,
                () => TextEditingController(),
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF17202C) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                            color: isPending
                                ? const Color(0xFFC28B45).withValues(alpha: 0.15)
                                : const Color(0xFF4D7C68).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isPending ? 'Pending Response' : 'Answered ✓',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPending ? const Color(0xFFC28B45) : const Color(0xFF4D7C68),
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final marjaStr = q.marjaComparison.isNotEmpty
                                ? (q.marjaComparison.first['marja'] ?? 'SISTANI')
                                : 'SISTANI';
                            return Text(
                              'Marja: ${marjaStr.toUpperCase()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q.text,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (isPending) ...[
                      TextField(
                        controller: ctrl,
                        maxLines: 3,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
                        decoration: InputDecoration(
                          hintText: 'Type official scholar response with citations...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white12 : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D7C68),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : () => _submitAnswer(q, scholarName),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Publish Answer',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ] else ...[
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
                              'Answered by ${q.answeredBy ?? 'Scholar'}:',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4D7C68),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q.scholarAnswer ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
