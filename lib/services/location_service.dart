import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiaVenueModel {
  final String id;
  final String name;
  final String type; // 'Masjid', 'Imambargah', 'Islamic Center', 'Haram'
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final String? adminUserId;
  final bool isClaimed;

  const ShiaVenueModel({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.adminUserId,
    this.isClaimed = false,
  });

  factory ShiaVenueModel.fromMap(Map<String, dynamic> map, String id) {
    return ShiaVenueModel(
      id: id,
      name: map['name'] ?? 'Shia Center',
      type: map['type'] ?? 'Masjid / Imambargah',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      adminUserId: map['adminUserId'],
      isClaimed: map['isClaimed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'adminUserId': adminUserId,
      'isClaimed': isClaimed,
    };
  }

  ShiaVenueModel copyWith({double? distanceKm, bool? isClaimed, String? adminUserId}) {
    return ShiaVenueModel(
      id: id,
      name: name,
      type: type,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      adminUserId: adminUserId ?? this.adminUserId,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class LocationService {
  /// Default Fallback location (Mumbra / Thane / Mumbai region)
  static const double defaultLat = 19.1764;
  static const double defaultLng = 73.0232;
  static const String defaultCity = 'Mumbra';

  /// Predefined curated Shia centers for guaranteed reliable local results
  static final List<ShiaVenueModel> curatedVenues = [
    const ShiaVenueModel(
      id: 'venue_mumbra_1',
      name: 'Masjid-e-Zainabia & Imambargah',
      type: 'Masjid & Imambargah',
      address: 'Kausa, Mumbra, Thane, Maharashtra',
      city: 'Mumbra',
      latitude: 19.1770,
      longitude: 73.0250,
    ),
    const ShiaVenueModel(
      id: 'venue_mumbra_2',
      name: 'Markaz-e-Ahlulbayt (a.s.) Center',
      type: 'Islamic Center & Hall',
      address: 'Amrut Nagar, Mumbra, Thane',
      city: 'Mumbra',
      latitude: 19.1820,
      longitude: 73.0210,
    ),
    const ShiaVenueModel(
      id: 'venue_mumbai_1',
      name: 'Mughal Masjid (Iranian Shia Masjid)',
      type: 'Masjid & Heritage',
      address: 'Imambada Road, Bhindi Bazaar, Mumbai',
      city: 'Dongri',
      latitude: 18.9612,
      longitude: 72.8340,
    ),
    const ShiaVenueModel(
      id: 'venue_mumbai_2',
      name: 'Bab-ul-Hawaij Imambargah',
      type: 'Imambargah',
      address: 'Pala Galli, Dongri, Mumbai',
      city: 'Dongri',
      latitude: 18.9580,
      longitude: 72.8370,
    ),
    const ShiaVenueModel(
      id: 'venue_mumbai_3',
      name: 'Khoja Shia Isna Ashari Jamaat Masjid',
      type: 'Masjid & Imambada',
      address: 'Pala Gali, Nishanpada Road, Dongri, Mumbai',
      city: 'Dongri',
      latitude: 18.9565,
      longitude: 72.8355,
    ),
    const ShiaVenueModel(
      id: 'venue_lucknow_1',
      name: 'Bara Imambara (Asfi Imambara)',
      type: 'Imambara & Jafari Mosque',
      address: 'Husainabad, Lucknow, Uttar Pradesh',
      city: 'Lucknow',
      latitude: 26.8690,
      longitude: 80.9126,
    ),
    const ShiaVenueModel(
      id: 'venue_lucknow_2',
      name: 'Chhota Imambara (Husainabad)',
      type: 'Imambargah',
      address: 'Husainabad Trust, Lucknow',
      city: 'Lucknow',
      latitude: 26.8744,
      longitude: 80.9048,
    ),
    const ShiaVenueModel(
      id: 'venue_karachi_1',
      name: 'Mehfil-e-Murtaza Imambargah',
      type: 'Imambargah & Community Center',
      address: 'PECHS Block 2, Karachi, Pakistan',
      city: 'Karachi',
      latitude: 24.8715,
      longitude: 67.0599,
    ),
    const ShiaVenueModel(
      id: 'venue_karachi_2',
      name: 'Masjid-o-Imambargah Yasrab',
      type: 'Masjid & Imambargah',
      address: 'DHA Phase 4, Karachi',
      city: 'Karachi',
      latitude: 24.8182,
      longitude: 67.0583,
    ),
    const ShiaVenueModel(
      id: 'venue_najaf_1',
      name: 'Holy Shrine of Imam Ali (a.s.)',
      type: 'Haram & Sanctuary',
      address: 'Old City, Najaf al-Ashraf, Iraq',
      city: 'Najaf',
      latitude: 32.0003,
      longitude: 44.3142,
    ),
    const ShiaVenueModel(
      id: 'venue_karbala_1',
      name: 'Holy Shrine of Imam Hussain (a.s.) & Hazrat Abbas (a.s.)',
      type: 'Haram & Sanctuary',
      address: 'Bain al-Haramayn, Karbala al-Muqaddasa, Iraq',
      city: 'Karbala',
      latitude: 32.6160,
      longitude: 44.0324,
    ),
    const ShiaVenueModel(
      id: 'venue_london_1',
      name: 'Al-Khoei Foundation & Islamic Centre',
      type: 'Islamic Center & Hawza',
      address: 'Chevening Rd, London NW6 6TN, UK',
      city: 'London',
      latitude: 51.5422,
      longitude: -0.2036,
    ),
    const ShiaVenueModel(
      id: 'venue_dearborn_1',
      name: 'Islamic Center of America',
      type: 'Mosque & Cultural Center',
      address: '19500 Ford Rd, Dearborn, MI 48128, USA',
      city: 'Dearborn',
      latitude: 42.3481,
      longitude: -83.2201,
    ),
  ];

  /// Get current live location with graceful fallback
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 7),
        ),
      );
    } catch (e) {
      debugPrint('Location lookup note: $e');
      return null;
    }
  }

  /// Get nearby Shia masjids and imambargahs sorted by distance
  static Future<List<ShiaVenueModel>> getNearbyVenues({
    required double lat,
    required double lng,
    String? cityFilter,
  }) async {
    List<ShiaVenueModel> venues = List.from(curatedVenues);

    // Also attempt to load cached venues from Firestore for this region
    try {
      final snap = await FirebaseFirestore.instance
          .collection('venues')
          .limit(50)
          .get(const GetOptions(source: Source.serverAndCache));

      if (snap.docs.isNotEmpty) {
        final firestoreVenues = snap.docs
            .map((doc) => ShiaVenueModel.fromMap(doc.data(), doc.id))
            .toList();

        final ids = venues.map((v) => v.id).toSet();
        for (final fv in firestoreVenues) {
          if (!ids.contains(fv.id)) {
            venues.add(fv);
          }
        }
      }
    } catch (e) {
      debugPrint('Firestore venues note: $e');
    }

    // Try Overpass API query if connected and add fresh nearby Shia places
    try {
      final overpassVenues = await _fetchFromOverpass(lat, lng);
      final ids = venues.map((v) => v.id).toSet();
      for (final ov in overpassVenues) {
        if (!ids.contains(ov.id)) {
          venues.add(ov);
          // Cache in Firestore in background
          _cacheVenueToFirestore(ov);
        }
      }
    } catch (e) {
      debugPrint('Overpass fetch note: $e');
    }

    // Filter by city if user selected manual area
    if (cityFilter != null && cityFilter.isNotEmpty && cityFilter != 'All') {
      final filtered = venues
          .where((v) =>
              v.city.toLowerCase() == cityFilter.toLowerCase() ||
              v.address.toLowerCase().contains(cityFilter.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) {
        venues = filtered;
      }
    }

    // Compute distance and sort
    final calculated = venues.map((v) {
      final distMeters = Geolocator.distanceBetween(
        lat,
        lng,
        v.latitude,
        v.longitude,
      );
      return v.copyWith(distanceKm: distMeters / 1000.0);
    }).toList();

    calculated.sort((a, b) => (a.distanceKm ?? 9999).compareTo(b.distanceKm ?? 9999));
    return calculated;
  }

  /// Query OpenStreetMap Overpass API for places of worship tagged Shia or Imambada
  static Future<List<ShiaVenueModel>> _fetchFromOverpass(double lat, double lng) async {
    final query = '''
[out:json][timeout:10];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:25000,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:25000,$lat,$lng);
);
out center 15;
''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    final response = await http
        .post(url, body: {'data': query})
        .timeout(const Duration(seconds: 6));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final elements = data['elements'] as List<dynamic>? ?? [];

      final List<ShiaVenueModel> results = [];
      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        final name = tags['name'] ?? tags['name:en'] ?? '';
        if (name.isEmpty) continue;

        final denomination = tags['denomination'] ?? '';
        final isShia = denomination.toString().toLowerCase().contains('shia') ||
            name.toString().toLowerCase().contains('shia') ||
            name.toString().toLowerCase().contains('imambargah') ||
            name.toString().toLowerCase().contains('imambada') ||
            name.toString().toLowerCase().contains('ahlulbayt') ||
            name.toString().toLowerCase().contains('zainab') ||
            name.toString().toLowerCase().contains('hussain') ||
            name.toString().toLowerCase().contains('ali');

        if (isShia) {
          final double elLat = (el['lat'] ?? el['center']?['lat'] ?? 0.0).toDouble();
          final double elLng = (el['lon'] ?? el['center']?['lon'] ?? 0.0).toDouble();
          if (elLat != 0.0 && elLng != 0.0) {
            results.add(
              ShiaVenueModel(
                id: 'osm_${el['id']}',
                name: name,
                type: name.toString().toLowerCase().contains('imamb')
                    ? 'Imambargah'
                    : 'Masjid',
                address: tags['addr:street'] ?? tags['addr:full'] ?? 'OpenStreetMap verified',
                city: tags['addr:city'] ?? '',
                latitude: elLat,
                longitude: elLng,
              ),
            );
          }
        }
      }
      return results;
    }
    return [];
  }

  static Future<void> _cacheVenueToFirestore(ShiaVenueModel venue) async {
    try {
      await FirebaseFirestore.instance
          .collection('venues')
          .doc(venue.id)
          .set(venue.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }
}
