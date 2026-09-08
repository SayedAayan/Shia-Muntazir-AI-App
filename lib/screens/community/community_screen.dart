import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            tabs: [
              Tab(text: 'Events & Majalis', icon: Icon(Icons.event_rounded)),
              Tab(text: 'Mosque / Imambara Map', icon: Icon(Icons.map_rounded)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Community Majalis & Events List (Phase 9)')),
            Center(child: Text('OpenStreetMap Mosque & Imambara Locator (Phase 9)')),
          ],
        ),
      ),
    );
  }
}
