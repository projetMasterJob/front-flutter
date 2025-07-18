import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/location_service.dart';
import 'home_tab.dart';
import 'models/point.dart';
import 'skeleton_loader.dart';

class HomeListPage extends StatefulWidget {
  final String search;
  final ListSortOption sort;
  final void Function(String type, {String? id})? onNavigateToDetail;
  const HomeListPage({Key? key, required this.search, required this.sort, this.onNavigateToDetail}) : super(key: key);

  @override
  _HomeListPageState createState() => _HomeListPageState();
}

class _HomeListPageState extends State<HomeListPage> {
  List<dynamic> companies = [];
  List<dynamic> jobs = [];
  bool isLoading = true;
  LatLng? userPosition;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { isLoading = true; });
    await _getUserPosition();
    final companiesRes = await http.get(Uri.parse('https://cartographielocal.vercel.app/companies'));
    final jobsRes = await http.get(Uri.parse('https://cartographielocal.vercel.app/jobs'));
    setState(() {
      companies = companiesRes.statusCode == 200 ? json.decode(companiesRes.body) : [];
      jobs = jobsRes.statusCode == 200 ? json.decode(jobsRes.body) : [];
      isLoading = false;
    });
  }

  Future<void> _getUserPosition() async {
    try {
      userPosition = await LocationService.getCurrentLocation();
    } catch (e) {
      userPosition = null;
    }
  }

  double? _getDistance(Map item) {
    if (userPosition == null || item['location'] == null) return null;
    return LocationService.calculateDistance(
      userPosition!,
      LatLng(item['location']['latitude'], item['location']['longitude'])
    );
  }

  List<Map> _filteredAndSortedItems() {
    final search = widget.search.toLowerCase();
    List<Map> items = [
      ...companies.where((c) => search.isEmpty || (c['name']?.toLowerCase().contains(search) ?? false)),
      ...jobs.where((j) => search.isEmpty || (j['title']?.toLowerCase().contains(search) ?? false)),
    ].cast<Map>();
    // Ajout de la distance pour le tri
    for (var item in items) {
      item['__distance'] = _getDistance(item) ?? double.infinity;
    }
    switch (widget.sort) {
      case ListSortOption.nameAZ:
        items.sort((a, b) => ((a['name'] ?? a['title']) ?? '').toString().toLowerCase().compareTo(((b['name'] ?? b['title']) ?? '').toString().toLowerCase()));
        break;
      case ListSortOption.nameZA:
        items.sort((a, b) => ((b['name'] ?? b['title']) ?? '').toString().toLowerCase().compareTo(((a['name'] ?? a['title']) ?? '').toString().toLowerCase()));
        break;
      case ListSortOption.distanceAsc:
        items.sort((a, b) => (a['__distance'] as double).compareTo(b['__distance'] as double));
        break;
      case ListSortOption.distanceDesc:
        items.sort((a, b) => (b['__distance'] as double).compareTo(a['__distance'] as double));
        break;
    }
    return items;
  }

  Widget _buildItem(Map item) {
    final location = item['location'] ?? {};
    final point = Point(
      id: item['id'],
      latitude: location['latitude'] ?? 0.0,
      longitude: location['longitude'] ?? 0.0,
      title: item['title'] ?? item['name'] ?? '',
      description: item['description'] ?? '',
      address: location['address'] ?? '',
      cp: location['cp'] ?? '',
      entity_type: location['entity_type'] ?? (item['title'] != null ? 'job' : 'company'),
      image_url: item['image_url'] ?? '',
    );
    final distance = _getDistance(item);
    const double badgeMinWidth = 70;
    return InkWell(
      onTap: () {
        if (widget.onNavigateToDetail != null) {
          widget.onNavigateToDetail!(point.entity_type, id: point.id);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              spreadRadius: 0.5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    point.image_url,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SkeletonLoader(
                        width: 50,
                        height: 50,
                        borderRadius: BorderRadius.circular(8),
                      );
                    },
                    errorBuilder: (c, e, s) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: distance != null ? badgeMinWidth : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          point.title,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          point.address,
                          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((point.cp.isNotEmpty) || distance != null)
                          SizedBox(height: 6),
                        if (point.cp.isNotEmpty)
                          Text(
                            point.cp,
                            style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (distance != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  constraints: BoxConstraints(minWidth: badgeMinWidth),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFECF4FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.directions_walk, size: 14, color: Color(0xFF3264E0)),
                      SizedBox(width: 4),
                      Text(
                        '${distance.toStringAsFixed(2)} km',
                        style: TextStyle(
                          color: Color(0xFF3264E0),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map> items = _filteredAndSortedItems();
    return Container(
      color: Color(0xFFF5F5F5),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              itemCount: items.length,
              itemBuilder: (context, i) => _buildItem(items[i]),
            ),
    );
  }
}
