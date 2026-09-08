import 'package:flutter/material.dart';

class QuranDuasScreen extends StatelessWidget {
  const QuranDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quran & Duas', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            tabs: [
              Tab(text: 'Holy Quran'),
              Tab(text: 'Duas'),
              Tab(text: 'Ziyarat'),
              Tab(text: 'Qadha Tracker'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Holy Quran browsable by Surah (Phase 7)')),
            Center(child: Text('Duas Library (Phase 4 & 7)')),
            Center(child: Text('Ziyarat Library (Phase 4 & 7)')),
            Center(child: Text('Qadha Tracker for Namaz & Roza (Phase 7)')),
          ],
        ),
      ),
    );
  }
}
