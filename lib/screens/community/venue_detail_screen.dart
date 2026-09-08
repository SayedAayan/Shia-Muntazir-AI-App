import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final ShiaVenueModel venue;

  const VenueDetailScreen({super.key, required this.venue});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen> {
  late ShiaVenueModel _venue;

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;
  }

  void _showClaimDialog() {
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final refCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Claim Venue Admin Rights',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request administrative access to manage "${_venue.name}". Requests are reviewed by community moderators.',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your Role at Venue (e.g. Trustee, Mutawalli, Volunteer)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reference / Community Member Name',
                    border: OutlineInputBorder(),
                  ),
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
                final authUser = ref.read(authStateProvider).value;
                final userId = authUser?.uid ?? 'guest_user';

                final claimId = 'claim_${DateTime.now().millisecondsSinceEpoch}';
                await FirebaseFirestore.instance.collection('venue_claims').doc(claimId).set({
                  'claimId': claimId,
                  'venueId': _venue.id,
                  'venueName': _venue.name,
                  'userId': userId,
                  'phoneNumber': phoneCtrl.text.trim(),
                  'roleAtVenue': roleCtrl.text.trim(),
                  'referenceName': refCtrl.text.trim(),
                  'status': 'pending_approval',
                  'city': _venue.city,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Color(0xFF4D7C68),
                      content: Text('Claim submitted! Community moderators will review your verification.'),
                    ),
                  );
                }
              },
              child: const Text('Submit Claim'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog() {
    final titleCtrl = TextEditingController();
    final zakirCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Post Majlis / Event for ${_venue.name}',
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Event Title (e.g. Thursday Night Dua Kumayl)'),
                ),
                TextField(
                  controller: zakirCtrl,
                  decoration: const InputDecoration(labelText: 'Speaker / Zakir / Maulana'),
                ),
                TextField(
                  controller: timeCtrl,
                  decoration: const InputDecoration(labelText: 'Date & Time (e.g. Thursday 8:30 PM)'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description / Tabarruk / Details'),
                  maxLines: 2,
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
                    'venueId': _venue.id,
                    'venueName': _venue.name,
                    'title': titleCtrl.text.trim(),
                    'speaker': zakirCtrl.text.trim(),
                    'timings': timeCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'address': _venue.address,
                    'city': _venue.city,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Majlis / Event posted to venue page!')),
                  );
                }
              },
              child: const Text('Publish Event'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isVenueAdmin = userProfile?.uid != null &&
        (_venue.adminUserId == userProfile!.uid || userProfile.role == 'scholar' || userProfile.role == 'admin');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        title: Text(
          _venue.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(22),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC27351).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.mosque_rounded, color: Color(0xFFC27351), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _venue.name,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC28B45).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _venue.type.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC28B45),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC27351)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _venue.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_venue.distanceKm != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.near_me_outlined, size: 16, color: Color(0xFF4D7C68)),
                      const SizedBox(width: 6),
                      Text(
                        '${_venue.distanceKm!.toStringAsFixed(1)} km away from you',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4D7C68),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC27351),
                          side: const BorderSide(color: Color(0xFFC27351)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.verified_user_outlined, size: 18),
                        label: const Text('Claim Venue'),
                        onPressed: _showClaimDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (isVenueAdmin)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC27351),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Post Majlis'),
                          onPressed: _showAddEventDialog,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Venue Majalis & Events Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Majalis & Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                ),
              ),
              if (!isVenueAdmin)
                TextButton.icon(
                  onPressed: _showAddEventDialog,
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFFC27351)),
                  label: const Text('Add Event', style: TextStyle(color: Color(0xFFC27351), fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Stream of events for this venue from Firestore
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('events')
                .where('venueId', isEqualTo: _venue.id)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                // Show default weekly majlis for this venue
                return Container(
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC27351).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFC27351), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Weekly Thursday Night Dua Kumayl & Majlis',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Every Thursday after Salat al-Maghribayn. Recitation of Hadith al-Kisa, Dua Kumayl, followed by short lecture and Niyaz.',
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Timing: 8:30 PM • All Momineen welcome',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFC28B45)),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                        Text(
                          data['title'] ?? 'Majlis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                          ),
                        ),
                        if (data['speaker'] != null && data['speaker'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Speaker: ${data['speaker']}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFFC28B45), fontWeight: FontWeight.w600),
                          ),
                        ],
                        if (data['timings'] != null && data['timings'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${data['timings']}',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ],
                        if (data['description'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            data['description'],
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700]),
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
      ),
    );
  }
}
