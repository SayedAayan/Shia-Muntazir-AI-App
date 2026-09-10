import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/verification_models.dart';
import '../../providers/user_provider.dart';

class VerificationRequestScreen extends ConsumerStatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  ConsumerState<VerificationRequestScreen> createState() => _VerificationRequestScreenState();
}

class _VerificationRequestScreenState extends ConsumerState<VerificationRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  String _requestType = 'scholar'; // 'scholar' or 'venue_admin'

  // Common controllers
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Brother';
  final _mobileCtrl = TextEditingController();
  final _cityAreaCtrl = TextEditingController();

  // Scholar controllers
  final _hawzaCtrl = TextEditingController();
  final _ijazahCtrl = TextEditingController();
  final _marjaAffiliationCtrl = TextEditingController(text: 'Ayatollah Sistani');
  final List<String> _selectedLanguages = ['English', 'Urdu'];

  // Venue controllers
  final _venueNameCtrl = TextEditingController();
  final _venueAddressCtrl = TextEditingController();
  final _roleAtVenueCtrl = TextEditingController(text: 'Trustee / Organizer');
  final _venueContactCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate known user details
    final user = ref.read(currentUserProfileProvider).value;
    if (user != null) {
      _fullNameCtrl.text = user.name;
      if (user.age > 0) _ageCtrl.text = user.age.toString();
      _gender = user.gender == 'sister' ? 'Sister' : 'Brother';
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _mobileCtrl.dispose();
    _cityAreaCtrl.dispose();
    _hawzaCtrl.dispose();
    _ijazahCtrl.dispose();
    _marjaAffiliationCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueAddressCtrl.dispose();
    _roleAtVenueCtrl.dispose();
    _venueContactCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProfileProvider).value;
    final uid = user?.uid ?? 'anonymous_user';

    setState(() => _isSubmitting = true);

    try {
      final reqId = 'req_${DateTime.now().millisecondsSinceEpoch}';

      final request = RoleRequestModel(
        requestId: reqId,
        requestedBy: uid,
        requestType: _requestType,
        fullName: _fullNameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? 25,
        gender: _gender,
        mobileNumber: _mobileCtrl.text.trim(),
        cityArea: _cityAreaCtrl.text.trim(),
        // Scholar fields
        hawza: _requestType == 'scholar' ? _hawzaCtrl.text.trim() : null,
        ijazahDetails: _requestType == 'scholar' ? _ijazahCtrl.text.trim() : null,
        marjaAffiliation: _requestType == 'scholar' ? _marjaAffiliationCtrl.text.trim() : null,
        languages: _requestType == 'scholar' ? _selectedLanguages : [],
        // Venue fields
        venueName: _requestType == 'venue_admin' ? _venueNameCtrl.text.trim() : null,
        venueAddress: _requestType == 'venue_admin' ? _venueAddressCtrl.text.trim() : null,
        roleAtVenue: _requestType == 'venue_admin' ? _roleAtVenueCtrl.text.trim() : null,
        venueContactNumber: _requestType == 'venue_admin' ? _venueContactCtrl.text.trim() : null,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('role_requests')
          .doc(reqId)
          .set(request.toMap());

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF4D7C68), size: 28),
            SizedBox(width: 10),
            Text('Request Received', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your request to become a ${_requestType == "scholar" ? "Verified Scholar" : "Venue Administrator"} has been submitted.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A3D).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Our team will review your credentials and may contact you at ${_mobileCtrl.text.trim()} for phone verification before approval.',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1B2A3D)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can track your request status at any time from your Profile page.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC27351),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Return to Profile
            },
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          'Verification Request',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Top Explainer Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2A3D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Color(0xFFD4AF37), size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Community Role Application',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Muntazir grants dedicated tools to certified Shia scholars and official venue organizers.',
                          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Role Selection Toggle
            Text(
              'Select Role to Apply For',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _requestType = 'scholar'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _requestType == 'scholar'
                            ? const Color(0xFFC27351).withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF17202C) : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _requestType == 'scholar' ? const Color(0xFFC27351) : Colors.grey.withValues(alpha: 0.3),
                          width: _requestType == 'scholar' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: _requestType == 'scholar' ? const Color(0xFFC27351) : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Shia Scholar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: _requestType == 'scholar' ? const Color(0xFFC27351) : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _requestType = 'venue_admin'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _requestType == 'venue_admin'
                            ? const Color(0xFF4D7C68).withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF17202C) : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _requestType == 'venue_admin' ? const Color(0xFF4D7C68) : Colors.grey.withValues(alpha: 0.3),
                          width: _requestType == 'venue_admin' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.mosque_rounded,
                            color: _requestType == 'venue_admin' ? const Color(0xFF4D7C68) : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Venue Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: _requestType == 'venue_admin' ? const Color(0xFF4D7C68) : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Common Fields Section
            Text(
              'Personal & Contact Details',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _fullNameCtrl,
              label: 'Full Name',
              hint: 'e.g. Maulana Sayed Hasan',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _ageCtrl,
                    label: 'Age',
                    hint: '35',
                    icon: Icons.cake_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: _inputDecoration('Gender', Icons.wc_outlined, isDark),
                    dropdownColor: isDark ? const Color(0xFF17202C) : Colors.white,
                    items: const [
                      DropdownMenuItem(value: 'Brother', child: Text('Brother')),
                      DropdownMenuItem(value: 'Sister', child: Text('Sister')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _gender = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _mobileCtrl,
              label: 'Mobile Number (Primary Verification Contact)',
              hint: '+91 9876543210',
              icon: Icons.phone_rounded,
              isDark: isDark,
              keyboardType: TextInputType.phone,
              validator: (v) => (v == null || v.trim().length < 8) ? 'Valid phone number required for verification' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _cityAreaCtrl,
              label: 'City / Area',
              hint: 'e.g. Mumbra, Mumbai / Lucknow / Karachi',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'City / Area is required' : null,
            ),
            const SizedBox(height: 24),

            // Role-Conditional Fields
            if (_requestType == 'scholar') ...[
              Text(
                'Scholar Credentials',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _hawzaCtrl,
                label: 'Hawza / Madrasa Attended (Name & Years)',
                hint: 'e.g. Hawza Ilmiyya Qom (2012-2019) or Jamia Imamia',
                icon: Icons.school_outlined,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Hawza details are required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ijazahCtrl,
                label: 'Ijazah / Certification Details',
                hint: 'Granting scholar name & subject (Teaching / Narration / Ijtihad)',
                icon: Icons.history_edu_rounded,
                isDark: isDark,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _marjaAffiliationCtrl,
                label: 'Marja Affiliation / Representation',
                hint: 'e.g. Office of Grand Ayatollah Sistani',
                icon: Icons.account_balance_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Text(
                'Languages Spoken (for answering community questions)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['English', 'Urdu', 'Arabic', 'Farsi', 'Hindi', 'Gujarati'].map((lang) {
                  final isSelected = _selectedLanguages.contains(lang);
                  return FilterChip(
                    label: Text(lang, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC27351),
                    checkmarkColor: Colors.white,
                    onSelected: (checked) {
                      setState(() {
                        if (checked) {
                          _selectedLanguages.add(lang);
                        } else {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              Text(
                'Venue Details (Masjid / Imambargah)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _venueNameCtrl,
                label: 'Masjid / Imambargah Name',
                hint: 'e.g. Masjid-e-Iranian (Mogul Masjid)',
                icon: Icons.mosque_outlined,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Venue name is required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _venueAddressCtrl,
                label: 'Full Venue Address',
                hint: 'Full street address, landmark & pin code',
                icon: Icons.map_outlined,
                isDark: isDark,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Venue address is required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _roleAtVenueCtrl,
                label: 'Your Role / Relationship to Venue',
                hint: 'e.g. Managing Trustee, Event Organizer, Mutawalli',
                icon: Icons.badge_outlined,
                isDark: isDark,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Role at venue is required' : null,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _venueContactCtrl,
                label: 'Venue Official Contact Number (if different)',
                hint: 'Landline or office number for verification calls',
                icon: Icons.contact_phone_outlined,
                isDark: isDark,
                keyboardType: TextInputType.phone,
              ),
            ],
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC27351),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Verification Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFC27351), size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFC27351), width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
      decoration: _inputDecoration(label, icon, isDark).copyWith(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
      ),
    );
  }
}
