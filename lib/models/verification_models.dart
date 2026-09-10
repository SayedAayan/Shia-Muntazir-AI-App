import 'package:cloud_firestore/cloud_firestore.dart';

class RoleRequestModel {
  final String requestId;
  final String requestedBy; // UID of applicant
  final String requestType; // "scholar" | "venue_admin"
  final String fullName;
  final int age;
  final String gender;
  final String mobileNumber;
  final String cityArea;

  // Scholar-specific fields
  final String? hawza;
  final String? ijazahDetails;
  final String? marjaAffiliation;
  final List<String> languages;

  // Venue-specific fields
  final String? venueName;
  final String? venueAddress;
  final String? roleAtVenue; // trustee, regular organizer, caretaker, etc.
  final String? venueContactNumber;

  // Review status
  final String status; // "pending" | "approved" | "rejected"
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const RoleRequestModel({
    required this.requestId,
    required this.requestedBy,
    required this.requestType,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.cityArea,
    this.hawza,
    this.ijazahDetails,
    this.marjaAffiliation,
    this.languages = const [],
    this.venueName,
    this.venueAddress,
    this.roleAtVenue,
    this.venueContactNumber,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewNotes,
    this.reviewedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'requested_by': requestedBy,
      'request_type': requestType,
      'full_name': fullName,
      'age': age,
      'gender': gender,
      'mobile_number': mobileNumber,
      'city_area': cityArea,
      'hawza': hawza,
      'ijazah_details': ijazahDetails,
      'marja_affiliation': marjaAffiliation,
      'languages': languages,
      'venue_name': venueName,
      'venue_address': venueAddress,
      'role_at_venue': roleAtVenue,
      'venue_contact_number': venueContactNumber,
      'status': status,
      'reviewed_by': reviewedBy,
      'review_notes': reviewNotes,
      'reviewed_at': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory RoleRequestModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return RoleRequestModel(
      requestId: id,
      requestedBy: map['requested_by'] as String? ?? '',
      requestType: map['request_type'] as String? ?? 'scholar',
      fullName: map['full_name'] as String? ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      gender: map['gender'] as String? ?? 'unspecified',
      mobileNumber: map['mobile_number'] as String? ?? '',
      cityArea: map['city_area'] as String? ?? '',
      hawza: map['hawza'] as String?,
      ijazahDetails: map['ijazah_details'] as String?,
      marjaAffiliation: map['marja_affiliation'] as String?,
      languages: (map['languages'] as List?)?.map((e) => e.toString()).toList() ?? [],
      venueName: map['venue_name'] as String?,
      venueAddress: map['venue_address'] as String?,
      roleAtVenue: map['role_at_venue'] as String?,
      venueContactNumber: map['venue_contact_number'] as String?,
      status: map['status'] as String? ?? 'pending',
      reviewedBy: map['reviewed_by'] as String?,
      reviewNotes: map['review_notes'] as String?,
      reviewedAt: map['reviewed_at'] != null ? parseTime(map['reviewed_at']) : null,
      createdAt: parseTime(map['created_at']),
    );
  }
}

class PendingRoleAssignmentModel {
  final String email;
  final String role; // "scholar" | "venue_admin"
  final String? venueId;
  final String assignedBy;
  final DateTime assignedAt;

  const PendingRoleAssignmentModel({
    required this.email,
    required this.role,
    this.venueId,
    required this.assignedBy,
    required this.assignedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email.toLowerCase().trim(),
      'role': role,
      'venueId': venueId,
      'assigned_by': assignedBy,
      'assigned_at': Timestamp.fromDate(assignedAt),
    };
  }

  factory PendingRoleAssignmentModel.fromMap(Map<String, dynamic> map) {
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return PendingRoleAssignmentModel(
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'scholar',
      venueId: map['venueId'] as String?,
      assignedBy: map['assigned_by'] as String? ?? '',
      assignedAt: parseTime(map['assigned_at']),
    );
  }
}
