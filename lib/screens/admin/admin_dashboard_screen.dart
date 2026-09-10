import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/verification_models.dart';
import '../../models/clip_model.dart';
import '../../providers/user_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Direct Assignment state (Path A)
  final _directEmailCtrl = TextEditingController();
  String _directRole = 'scholar';
  final _directVenueNameCtrl = TextEditingController();
  bool _isDirectSubmitting = false;

  // Queue Filter state (Path B)
  String _typeFilter = 'all'; // 'all', 'scholar', 'venue_admin'
  String _cityFilter = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _directEmailCtrl.dispose();
    _directVenueNameCtrl.dispose();
    super.dispose();
  }

  // --- Path A: Direct Role Assignment ---
  Future<void> _handleDirectAssignment() async {
    final input = _directEmailCtrl.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address or UID.')),
      );
      return;
    }

    setState(() => _isDirectSubmitting = true);

    try {
      final currentUser = ref.read(currentUserProfileProvider).value;
      final adminUid = currentUser?.uid ?? 'superadmin';
      final userService = ref.read(userServiceProvider);

      String? venueId;
      if (_directRole == 'venue_admin' && _directVenueNameCtrl.text.trim().isNotEmpty) {
        venueId = 'venue_${DateTime.now().millisecondsSinceEpoch}';
        await FirebaseFirestore.instance.collection('venues').doc(venueId).set({
          'id': venueId,
          'name': _directVenueNameCtrl.text.trim(),
          'type': 'Masjid / Imambargah',
          'city': 'General',
          'isClaimed': true,
          'adminUserId': input.contains('@') ? null : input,
        });
      }

      final appliedImmediately = await userService.assignUserRole(
        emailOrUid: input,
        role: _directRole,
        venueId: venueId,
        adminUid: adminUid,
      );

      if (mounted) {
        _directEmailCtrl.clear();
        _directVenueNameCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4D7C68),
            content: Text(appliedImmediately
                ? 'Role granted immediately to existing user!'
                : 'Pending assignment saved! Role will auto-apply when $input signs up.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning role: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDirectSubmitting = false);
    }
  }

  // --- Path B: Approve Request ---
  Future<void> _approveRequest(RoleRequestModel request) async {
    final currentUser = ref.read(currentUserProfileProvider).value;
    final adminUid = currentUser?.uid ?? 'superadmin';

    try {
      String? venueId;

      if (request.requestType == 'venue_admin' && request.venueName != null) {
        final venueNameTrimmed = request.venueName!.trim().toLowerCase();

        // Check if venue already exists in 'venues' collection
        final existingVenues = await FirebaseFirestore.instance.collection('venues').get();
        final match = existingVenues.docs.where((doc) {
          final n = (doc.data()['name'] as String? ?? '').toLowerCase();
          return n == venueNameTrimmed;
        }).toList();

        if (match.isNotEmpty) {
          venueId = match.first.id;
          await FirebaseFirestore.instance.collection('venues').doc(venueId).update({
            'isClaimed': true,
            'adminUserId': request.requestedBy,
          });
        } else {
          // Auto-create venue document as part of approval
          venueId = 'venue_${DateTime.now().millisecondsSinceEpoch}';
          await FirebaseFirestore.instance.collection('venues').doc(venueId).set({
            'id': venueId,
            'name': request.venueName!.trim(),
            'address': request.venueAddress ?? '',
            'city': request.cityArea,
            'type': 'Masjid / Imambargah',
            'latitude': 19.0760, // Default region or geocoded
            'longitude': 72.8777,
            'isClaimed': true,
            'adminUserId': request.requestedBy,
          });
        }
      }

      // Update role request status
      await FirebaseFirestore.instance
          .collection('role_requests')
          .doc(request.requestId)
          .update({
        'status': 'approved',
        'reviewed_by': adminUid,
        'reviewed_at': FieldValue.serverTimestamp(),
      });

      // Update target user's role in 'users' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(request.requestedBy)
          .update({
        'role': request.requestType,
        'venueId': ?venueId,
        'can_upload_reel': true,
        'mobile_number': request.mobileNumber,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4D7C68),
            content: Text('${request.fullName} approved as ${request.requestType}!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving request: $e')),
        );
      }
    }
  }

  // --- Path B: Reject Request ---
  Future<void> _rejectRequest(RoleRequestModel request) async {
    final currentUser = ref.read(currentUserProfileProvider).value;
    final adminUid = currentUser?.uid ?? 'superadmin';
    final notesCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Verification Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject the application for ${request.fullName}?'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Internal review notes (optional)',
                hintText: 'e.g. Phone number unreachable / info incomplete',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('role_requests')
          .doc(request.requestId)
          .update({
        'status': 'rejected',
        'reviewed_by': adminUid,
        'review_notes': notesCtrl.text.trim(),
        'reviewed_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request marked as rejected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: $e')),
        );
      }
    }
  }

  // --- Safety: Kill Switch on Clips ---
  Future<void> _hideClip(String reelId) async {
    await FirebaseFirestore.instance.collection('reels').doc(reelId).update({'is_hidden': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.orange, content: Text('Clip has been hidden from public feed.')),
      );
    }
  }

  Future<void> _deleteClip(String reelId) async {
    await FirebaseFirestore.instance.collection('reels').doc(reelId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('Clip permanently deleted.')),
      );
    }
  }

  Future<void> _revokeUserUploadPermission(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'can_upload_reel': false});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red[800], content: Text('Upload permission revoked for user $uid.')),
      );
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
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Superadmin Control Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
            Tab(text: 'Review Queue'),
            Tab(text: 'Direct Assign'),
            Tab(text: 'Clips Moderation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewQueueTab(isDark),
          _buildDirectAssignTab(isDark),
          _buildClipsModerationTab(isDark),
        ],
      ),
    );
  }

  // TAB 1: Role Verification Queue
  Widget _buildReviewQueueTab(bool isDark) {
    return Column(
      children: [
        // Filter row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: isDark ? const Color(0xFF141C26) : Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Text('Filter:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white70 : Colors.black87)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('All', style: TextStyle(fontSize: 11)),
                    selected: _typeFilter == 'all',
                    selectedColor: const Color(0xFFC27351),
                    labelStyle: TextStyle(color: _typeFilter == 'all' ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                    onSelected: (_) => setState(() => _typeFilter = 'all'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Scholars', style: TextStyle(fontSize: 11)),
                    selected: _typeFilter == 'scholar',
                    selectedColor: const Color(0xFFC27351),
                    labelStyle: TextStyle(color: _typeFilter == 'scholar' ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                    onSelected: (_) => setState(() => _typeFilter = 'scholar'),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Venues', style: TextStyle(fontSize: 11)),
                    selected: _typeFilter == 'venue_admin',
                    selectedColor: const Color(0xFF4D7C68),
                    labelStyle: TextStyle(color: _typeFilter == 'venue_admin' ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                    onSelected: (_) => setState(() => _typeFilter = 'venue_admin'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Filter by city / area...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => setState(() => _cityFilter = v.trim()),
                ),
              ),
            ],
          ),
        ),

        // Requests stream
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('role_requests').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
              }

              var docs = snapshot.data!.docs.map((d) => RoleRequestModel.fromMap(d.data(), d.id)).toList();

              // Sort pending first, then by date descending
              docs.sort((a, b) {
                if (a.status == 'pending' && b.status != 'pending') return -1;
                if (a.status != 'pending' && b.status == 'pending') return 1;
                return b.createdAt.compareTo(a.createdAt);
              });

              // Apply filters
              if (_typeFilter != 'all') {
                docs = docs.where((d) => d.requestType == _typeFilter).toList();
              }
              if (_cityFilter.isNotEmpty) {
                docs = docs.where((d) => d.cityArea.toLowerCase().contains(_cityFilter.toLowerCase())).toList();
              }

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No verification requests found.', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final req = docs[index];
                  return _buildRequestCard(req, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(RoleRequestModel req, bool isDark) {
    final isPending = req.status == 'pending';
    final isScholar = req.requestType == 'scholar';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? const Color(0xFFC27351).withValues(alpha: 0.4)
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isScholar
                  ? const Color(0xFFC27351).withValues(alpha: 0.1)
                  : const Color(0xFF4D7C68).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isScholar ? Icons.school_rounded : Icons.mosque_rounded,
                      size: 18,
                      color: isScholar ? const Color(0xFFC27351) : const Color(0xFF4D7C68),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isScholar ? 'SCHOLAR APPLICANT' : 'VENUE ADMIN APPLICANT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isScholar ? const Color(0xFFC27351) : const Color(0xFF4D7C68),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.2)
                        : (req.status == 'approved' ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPending ? Colors.orange[800] : (req.status == 'approved' ? Colors.green[800] : Colors.red[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      req.fullName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    Text(
                      '${req.age} yrs • ${req.gender}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(req.cityArea, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 12),

                // Prominent Phone Number (A.3: primary manual verification step)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req.mobileNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.blue),
                        tooltip: 'Copy Number',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: req.mobileNumber));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Phone number copied to clipboard.')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded, size: 18, color: Colors.green),
                        tooltip: 'Call for Verification',
                        onPressed: () => launchUrl(Uri.parse('tel:${req.mobileNumber}')),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Conditional Credentials Summary
                if (isScholar) ...[
                  if (req.hawza != null)
                    Text('Hawza: ${req.hawza}', style: const TextStyle(fontSize: 12.5)),
                  if (req.marjaAffiliation != null)
                    Text('Marja: ${req.marjaAffiliation}', style: const TextStyle(fontSize: 12.5)),
                  if (req.languages.isNotEmpty)
                    Text('Languages: ${req.languages.join(", ")}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ] else ...[
                  if (req.venueName != null)
                    Text('Venue: ${req.venueName}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  if (req.venueAddress != null)
                    Text('Address: ${req.venueAddress}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  if (req.roleAtVenue != null)
                    Text('Role at Venue: ${req.roleAtVenue}', style: const TextStyle(fontSize: 12.5)),
                ],

                // Action Buttons for Pending Requests
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text('Reject'),
                          onPressed: () => _rejectRequest(req),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4D7C68),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Approve Role'),
                          onPressed: () => _approveRequest(req),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Direct Role Assignment (Path A)
  Widget _buildDirectAssignTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFC27351), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Direct Role Assignment (Fast Path)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Assign the Scholar or Venue Admin role to known and trusted individuals. If the user hasn\'t signed up yet, this creates a pending assignment that auto-activates when they first log in.',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 20),

              // Email / UID input
              TextField(
                controller: _directEmailCtrl,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
                decoration: InputDecoration(
                  labelText: 'Google Account Email or Firebase UID',
                  hintText: 'scholar@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFC27351)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),

              // Role selection dropdown
              DropdownButtonFormField<String>(
                initialValue: _directRole,
                decoration: InputDecoration(
                  labelText: 'Role to Grant',
                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFFC27351)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                dropdownColor: isDark ? const Color(0xFF17202C) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'scholar', child: Text('Scholar (Fiqh & Reflections)')),
                  DropdownMenuItem(value: 'venue_admin', child: Text('Venue Admin (Masjid / Imambargah)')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _directRole = v);
                },
              ),
              const SizedBox(height: 16),

              if (_directRole == 'venue_admin') ...[
                TextField(
                  controller: _directVenueNameCtrl,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
                  decoration: InputDecoration(
                    labelText: 'Venue Name (e.g. Mogul Masjid)',
                    prefixIcon: const Icon(Icons.mosque_outlined, color: Color(0xFF4D7C68)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC27351),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isDirectSubmitting ? null : _handleDirectAssignment,
                  child: _isDirectSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Grant / Queue Role Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // List of pending role assignments
        Text('Queued Pending Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1B2A3D))),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('pending_role_assignments').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Text('No pending pre-assignments in queue.', style: TextStyle(color: Colors.grey[500], fontSize: 13));
            }
            return Column(
              children: docs.map((d) {
                final data = d.data();
                return ListTile(
                  tileColor: isDark ? const Color(0xFF17202C) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  leading: const Icon(Icons.pending_actions_rounded, color: Colors.orange),
                  title: Text(data['email'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Role: ${data["role"]} • Awaiting first login', style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                    onPressed: () => d.reference.delete(),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // TAB 3: Clips Moderation & Kill Switch (B.8)
  Widget _buildClipsModerationTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Reported clips queue
        Text(
          'Flagged Clips Queue (User Reports)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('reel_reports').where('status', isEqualTo: 'pending').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs.map((d) => ClipReportModel.fromMap(d.data(), d.id)).toList();
            if (docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF17202C) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF4D7C68), size: 20),
                    SizedBox(width: 10),
                    Text('No reported clips pending review.', style: TextStyle(fontSize: 13)),
                  ],
                ),
              );
            }
            return Column(
              children: docs.map((rep) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('Report for Clip: ${rep.reelId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Reason: ${rep.reason}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_off_rounded, color: Colors.orange),
                          tooltip: 'Hide Clip',
                          onPressed: () => _hideClip(rep.reelId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                          tooltip: 'Delete Clip Permanently',
                          onPressed: () => _deleteClip(rep.reelId),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),

        // Active clips library with quick kill switch
        Text(
          'All Clips & Admin Kill Switch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('reels').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            final docs = snapshot.data!.docs.map((d) => ClipModel.fromMap(d.data(), d.id)).toList();
            if (docs.isEmpty) {
              return Text('No clips published yet.', style: TextStyle(color: Colors.grey[500]));
            }
            return Column(
              children: docs.map((clip) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17202C) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          image: clip.thumbnailUrl.isNotEmpty
                              ? DecorationImage(image: NetworkImage(clip.thumbnailUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: clip.thumbnailUrl.isEmpty
                            ? const Icon(Icons.videocam_rounded, color: Colors.white54)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clip.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            Text(
                              'By: ${clip.authorName} (${clip.roleAtUpload})',
                              style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                            ),
                            if (clip.isHidden)
                              const Text('HIDDEN FROM FEED', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(clip.isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.orange, size: 20),
                        tooltip: clip.isHidden ? 'Unhide Clip' : 'Hide Clip',
                        onPressed: () {
                          FirebaseFirestore.instance.collection('reels').doc(clip.reelId).update({'is_hidden': !clip.isHidden});
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.block_rounded, color: Colors.red, size: 20),
                        tooltip: 'Revoke Upload Access for User',
                        onPressed: () => _revokeUserUploadPermission(clip.uploadedBy),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                        tooltip: 'Delete Clip',
                        onPressed: () => _deleteClip(clip.reelId),
                      ),
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
