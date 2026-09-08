import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';
import 'venue_detail_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final MapController _mapController = MapController();
  List<ShiaVenueModel> _venues = [];
  bool _isLoading = true;
  bool _isMapView = false;
  String _selectedCityFilter = 'Live Location';
  double _currentLat = LocationService.defaultLat;
  double _currentLng = LocationService.defaultLng;
  String _searchQuery = '';

  final List<String> _quickCities = [
    'Live Location',
    'Mumbra',
    'Dongri',
    'Lucknow',
    'Karachi',
    'Najaf',
    'Karbala',
    'London',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLiveVenues();
  }

  Future<void> _fetchLiveVenues([String? city]) async {
    setState(() => _isLoading = true);

    if (city == null || city == 'Live Location') {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      }
    } else {
      // Find matching coordinates from curated centers for selected city
      final match = LocationService.curatedVenues.firstWhere(
        (v) => v.city.toLowerCase() == city.toLowerCase(),
        orElse: () => LocationService.curatedVenues.first,
      );
      _currentLat = match.latitude;
      _currentLng = match.longitude;
    }

    final venues = await LocationService.getNearbyVenues(
      lat: _currentLat,
      lng: _currentLng,
      cityFilter: (city == null || city == 'Live Location') ? null : city,
    );

    if (mounted) {
      setState(() {
        _venues = venues;
        _isLoading = false;
      });
      if (_isMapView) {
        _mapController.move(LatLng(_currentLat, _currentLng), 12.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredVenues = _venues.where((v) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return v.name.toLowerCase().contains(q) ||
          v.address.toLowerCase().contains(q) ||
          v.type.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        title: Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_outlined,
              color: const Color(0xFFC27351),
            ),
            tooltip: _isMapView ? 'Show List View' : 'Show Map View',
            onPressed: () {
              setState(() => _isMapView = !_isMapView);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // City Filter & Live Location Chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: isDark ? const Color(0xFF141C26) : const Color(0xFFF2ECE1),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _quickCities.map((city) {
                final isSelected = _selectedCityFilter == city;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    avatar: city == 'Live Location'
                        ? const Icon(Icons.my_location_rounded, size: 14)
                        : null,
                    label: Text(city, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFC27351),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCityFilter = city);
                      _fetchLiveVenues(city);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFC27351)),
                hintText: 'Search Shia masjids & imambargahs...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF17202C) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),

          // Main View: List or Map
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)))
                : _isMapView
                    ? _buildMapView(filteredVenues, isDark)
                    : _buildListView(filteredVenues, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<ShiaVenueModel> venues, bool isDark) {
    if (venues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No Shia centers found for this filter. Try selecting another city or searching.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: venues.length,
      itemBuilder: (context, index) {
        final venue = venues[index];
        final isImambargah = venue.type.toLowerCase().contains('imamb');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            borderRadius: BorderRadius.circular(18),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => VenueDetailScreen(venue: venue),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (isImambargah
                                ? const Color(0xFFC28B45)
                                : const Color(0xFFC27351))
                            .withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isImambargah ? Icons.temple_buddhist_rounded : Icons.mosque_rounded,
                        color: isImambargah
                            ? const Color(0xFFC28B45)
                            : const Color(0xFFC27351),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            venue.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            venue.type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isImambargah
                                  ? const Color(0xFFC28B45)
                                  : const Color(0xFFC27351),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            venue.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          if (venue.distanceKm != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.near_me_outlined, size: 14, color: Color(0xFF4D7C68)),
                                const SizedBox(width: 4),
                                Text(
                                  '${venue.distanceKm!.toStringAsFixed(1)} km away',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4D7C68),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFFC27351),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<ShiaVenueModel> venues, bool isDark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(_currentLat, _currentLng),
        initialZoom: 11.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.muntazir.muntazir',
        ),
        MarkerLayer(
          markers: venues.map((venue) {
            return Marker(
              point: LatLng(venue.latitude, venue.longitude),
              width: 46,
              height: 46,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => VenueDetailScreen(venue: venue),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFC27351),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
