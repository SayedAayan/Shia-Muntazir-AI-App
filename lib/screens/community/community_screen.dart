import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/companion_models.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final MapController _mapController = MapController();

  // Selected center for map preview
  Map<String, dynamic>? _selectedCenter;

  static final List<Map<String, dynamic>> _shiaCenters = [
    {
      'name': 'Imam Ali (a.s.) Holy Shrine',
      'city': 'Najaf al-Ashraf',
      'lat': 32.0003,
      'lng': 44.3142,
      'address': 'Holy City of Najaf, Iraq',
      'type': 'Haram & Jafari Center',
    },
    {
      'name': 'Imam Hussain (a.s.) Holy Shrine',
      'city': 'Karbala al-Muqaddasa',
      'lat': 32.6160,
      'lng': 44.0324,
      'address': 'Holy City of Karbala, Iraq',
      'type': 'Haram & Spiritual Sanctuary',
    },
    {
      'name': 'Mughal Masjid (Shia Jama Masjid)',
      'city': 'Mumbai',
      'lat': 18.9612,
      'lng': 72.8340,
      'address': 'Imambada Road, Bhindi Bazaar, Mumbai',
      'type': 'Imambara & Mosque',
    },
    {
      'name': 'Mehfil-e-Murtaza Imambargah',
      'city': 'Karachi',
      'lat': 24.8715,
      'lng': 67.0599,
      'address': 'PECHS Block 2, Karachi, Pakistan',
      'type': 'Imambargah & Community Hall',
    },
    {
      'name': 'Al-Khoei Foundation & Islamic Centre',
      'city': 'London',
      'lat': 51.5422,
      'lng': -0.2036,
      'address': 'Chevening Rd, London NW6 6TN, UK',
      'type': 'Islamic Center & Hawza',
    },
    {
      'name': 'Islamic Center of America',
      'city': 'Dearborn',
      'lat': 42.3481,
      'lng': -83.2201,
      'address': '19500 Ford Rd, Dearborn, MI 48128, USA',
      'type': 'Mosque & Cultural Center',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
          elevation: 0,
          title: Text(
            'Around you',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFC27351),
            indicatorWeight: 3,
            labelColor: const Color(0xFFC27351),
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Majalis & Events', icon: Icon(Icons.calendar_month_rounded, size: 20)),
              Tab(text: 'Mosques & Imambaras', icon: Icon(Icons.place_rounded, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEventsTab(isDark),
            _buildMapTab(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab(bool isDark) {
    final now = DateTime.now();

    final initialEvents = [
      CommunityEventModel(
        eventId: 'event_1',
        title: 'Thursday Night Dua Kumayl & Majlis',
        type: 'majlis',
        latitude: 18.9612,
        longitude: 72.8340,
        address: 'Markaz-e-Ahlulbayt Community Hall, Imambada Road',
        date: now.add(const Duration(days: 1)),
        description: 'Weekly recitation of Dua Kumayl followed by reflections on Nahj al-Balagha and tabarruk.',
      ),
      CommunityEventModel(
        eventId: 'event_2',
        title: 'Friday Congregational Prayers (Jummah)',
        type: 'majlis',
        latitude: 24.8715,
        longitude: 67.0599,
        address: 'Central Shia Jame Masjid, Block 2',
        date: now.add(const Duration(days: 2)),
        description: 'Sermon on spiritual ethics followed by 2-rakat Salat al-Jummah with community gathering.',
      ),
      CommunityEventModel(
        eventId: 'event_3',
        title: 'Celebration: Milad of Imam al-Mahdi (a.t.f.s.)',
        type: 'majlis',
        latitude: 32.0003,
        longitude: 44.3142,
        address: 'Imam az-Zaman Cultural Hall, Old City',
        date: now.add(const Duration(days: 6)),
        description: 'Joyous gathering on 15th Shaban with Qasaid, spiritual lecture on Waiting (Intizar), and dinner.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC27351),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Majlis / Event', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEventDialog(context, isDark),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 80),
        itemCount: initialEvents.length,
        itemBuilder: (context, index) {
          final event = initialEvents[index];
          return _buildEventCard(event, isDark);
        },
      ),
    );
  }

  Widget _buildEventCard(CommunityEventModel event, bool isDark) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC27351).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.event_note_rounded, color: Color(0xFFC27351), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.event_seat_rounded, size: 14, color: Color(0xFFC28B45)),
                        const SizedBox(width: 4),
                        Text(
                          event.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC28B45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  event.address,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapTab(bool isDark) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(32.0003, 44.3142), // Centered at Najaf
            initialZoom: 5.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.muntazir.muntazir',
            ),
            MarkerLayer(
              markers: _shiaCenters.map((center) {
                return Marker(
                  point: LatLng(center['lat'] as double, center['lng'] as double),
                  width: 48,
                  height: 48,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCenter = center);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC27351),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Selected Center Bottom Card
        if (_selectedCenter != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF17202C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedCenter!['name'] as String,
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => setState(() => _selectedCenter = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCenter!['type'] as String,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC27351),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedCenter!['address'] as String,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D7C68),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 18),
                      label: const Text('Open Coordinates in Maps'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Center selected: ${_selectedCenter!['lat']}, ${_selectedCenter!['lng']}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showAddEventDialog(BuildContext context, bool isDark) {
    final titleCtrl = TextEditingController();
    final venueCtrl = TextEditingController();
    final speakerCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Add Community Event',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Event Title (e.g. Majlis-e-Aza)'),
                ),
                TextField(
                  controller: speakerCtrl,
                  decoration: const InputDecoration(labelText: 'Zakir / Speaker Name'),
                ),
                TextField(
                  controller: venueCtrl,
                  decoration: const InputDecoration(labelText: 'Venue / Imambara Name'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description / Timings'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC27351),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (titleCtrl.text.isNotEmpty) {
                  final eventId = 'ev_${DateTime.now().millisecondsSinceEpoch}';
                  await FirebaseFirestore.instance.collection('events').doc(eventId).set({
                    'eventId': eventId,
                    'title': titleCtrl.text.trim(),
                    'speaker': speakerCtrl.text.trim(),
                    'venue': venueCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Majlis / Event posted to community!')),
                  );
                }
              },
              child: const Text('Post Event'),
            ),
          ],
        );
      },
    );
  }
}
