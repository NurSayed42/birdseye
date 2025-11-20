import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/person_model.dart';
import '../models/geo_model.dart';
import '../services/json_service.dart';
import '../utils/constants.dart';

class MapPage extends StatefulWidget {
  final List<Person> persons;
  final String areaType;
  final String areaName;

  const MapPage({
    super.key,
    required this.persons,
    required this.areaType,
    required this.areaName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GeoJsonData? currentGeoData;
  bool isLoading = true;
  String currentLevel = 'division';

  @override
  void initState() {
    super.initState();
    loadGeoData();
  }

  Future<void> loadGeoData() async {
    try {
      String assetPath;
      
      switch (widget.areaType) {
        case 'division':
          assetPath = AppConstants.geoJsonPaths['divisions']!;
          currentLevel = 'division';
          break;
        case 'district':
          assetPath = AppConstants.geoJsonPaths['districts']!;
          currentLevel = 'district';
          break;
        case 'upazilla':
          assetPath = AppConstants.geoJsonPaths['upazilas']!;
          currentLevel = 'upazilla';
          break;
        case 'union':
          assetPath = AppConstants.geoJsonPaths['unions']!;
          currentLevel = 'union';
          break;
        default:
          assetPath = AppConstants.geoJsonPaths['bangladesh']!;
          currentLevel = 'country';
      }
      
      final geoData = await JsonService.loadGeoJson(assetPath);
      setState(() {
        currentGeoData = geoData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading geo data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToNextLevel(String areaName) {
    String nextLevel;
    switch (currentLevel) {
      case 'division':
        nextLevel = 'district';
        break;
      case 'district':
        nextLevel = 'upazilla';
        break;
      case 'upazilla':
        nextLevel = 'union';
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          persons: widget.persons,
          areaType: nextLevel,
          areaName: areaName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('লোড হচ্ছে...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.areaName} - মানচিত্র'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.table_chart),
            onPressed: () {
              // Navigate to data table
            },
          ),
        ],
      ),
      body: currentGeoData != null
          ? FlutterMap(
              options: MapOptions(
                center: _getCenterPoint(),
                zoom: _getZoomLevel(),
                onTap: (tapPosition, latLng) {
                  // Handle area tap
                  _handleMapTap(latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                PolygonLayer(
                  polygons: _buildPolygons(),
                ),
              ],
            )
          : Center(
              child: Text('মানচিত্র ডেটা লোড করতে সমস্যা হচ্ছে'),
            ),
    );
  }

  LatLng _getCenterPoint() {
    switch (currentLevel) {
      case 'division':
        return LatLng(23.6850, 90.3563);
      case 'district':
        return LatLng(23.6850, 90.3563);
      case 'upazilla':
        return LatLng(23.6850, 90.3563);
      case 'union':
        return LatLng(23.6850, 90.3563);
      default:
        return LatLng(23.6850, 90.3563);
    }
  }

  double _getZoomLevel() {
    switch (currentLevel) {
      case 'division':
        return 7.0;
      case 'district':
        return 8.0;
      case 'upazilla':
        return 9.0;
      case 'union':
        return 10.0;
      default:
        return 6.5;
    }
  }

  List<Polygon> _buildPolygons() {
    List<Polygon> polygons = [];

    for (var feature in currentGeoData!.features) {
      if (feature.geometry.type == 'MultiPolygon') {
        final coordinates = feature.geometry.coordinates;
        final properties = feature.properties;
        final areaName = properties['name'] ?? 'Unknown';

        // Calculate party stats
        final stats = JsonService.calculatePartyStats(
          widget.persons, 
          currentLevel, 
          areaName
        );

        Color areaColor = _getAreaColor(stats);

        for (var polygonGroup in coordinates) {
          for (var polygon in polygonGroup) {
            List<LatLng> points = [];
            for (var point in polygon) {
              if (point is List && point.length >= 2) {
                points.add(LatLng(point[1].toDouble(), point[0].toDouble()));
              }
            }

            polygons.add(
              Polygon(
                points: points,
                color: areaColor.withOpacity(0.6),
                borderColor: Colors.black,
                borderStrokeWidth: 1,
                isFilled: true,
              ),
            );
          }
        }
      }
    }

    return polygons;
  }

  Color _getAreaColor(Map<String, int> stats) {
    if (stats.isEmpty) return Colors.grey;

    String majorityParty = stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    switch (majorityParty) {
      case 'Awami League':
        return Colors.green;
      case 'BNP':
        return Colors.red;
      case 'Jatiya Party':
        return Colors.blue;
      case 'Jamaat-e-Islami':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  void _handleMapTap(LatLng latLng) {
    // Implement area detection logic here
    // This is a simplified version
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('এলাকা নির্বাচন'),
        content: Text('পরবর্তী লেভেলে যেতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('না'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToNextLevel('Sample Area');
            },
            child: Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }
}