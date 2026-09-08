import 'package:flutter/material.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask a Question', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Marja Comparison Mode',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Religious Disclaimer Banner (as required by prompt)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF26200A) : const Color(0xFFFFF9E6),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFB8860B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is informational — confirm with your marja\'s office for binding rulings.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFE8C86A) : const Color(0xFF7A5900),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('AI RAG Q&A & Scholar Queries (Phase 8)'),
            ),
          ),
        ],
      ),
    );
  }
}
