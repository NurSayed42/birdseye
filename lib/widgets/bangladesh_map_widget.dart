import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/geo_model.dart';
import '../models/person_model.dart';
import '../services/json_service.dart';

class BangladeshMapWidget extends StatelessWidget {
  final GeoJsonData geoData;
  final List<Person> persons;
  final String areaType;
  final String areaName;
  final Function(String) onAreaTap;

  const BangladeshMapWidget({
    super.key,
    required this.geoData,
    required this.persons,
    required this.areaType,
    required this.areaName,
    required this.onAreaTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: _getCenterPoint(),
        zoom: _getZoomLevel(),
        onTap: (tapPosition, latLng) {
          _handleMapTap(context, latLng);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.birdseye',
        ),
        PolygonLayer(
          polygons: _buildPolygons(),
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }

  LatLng _getCenterPoint() {
    switch (areaType) {
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
    switch (areaType) {
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

    for (var feature in geoData.features) {
      if (feature.geometry.type == 'MultiPolygon') {
        final coordinates = feature.geometry.coordinates;
        final properties = feature.properties;
        final areaName = properties['name'] ?? 'Unknown';

        final stats = JsonService.calculatePartyStats(persons, areaType, areaName);
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

    if (polygons.isEmpty) {
      polygons.add(
        Polygon(
          points: [
            LatLng(20.5, 88.0),
            LatLng(26.5, 88.0),
            LatLng(26.5, 92.5),
            LatLng(20.5, 92.5),
          ],
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
          isFilled: true,
        ),
      );
    }

    return polygons;
  }

  Color _getAreaColor(Map<String, int> stats) {
    if (stats.isEmpty) return Colors.grey;

    String majorityParty = '';
    int maxCount = 0;

    stats.forEach((party, count) {
      if (count > maxCount) {
        maxCount = count;
        majorityParty = party;
      }
    });

    switch (majorityParty) {
      case 'Jamaat-e-Islami':
        return Colors.purple;
      case 'BNP':
        return Colors.red;
      case 'Jatiya Party':
        return Colors.blue;
      case 'Awami League':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  void _handleMapTap(BuildContext context, LatLng latLng) {
    List<String> sampleDivisions = ['Dhaka', 'Chittagong', 'Rajshahi', 'Khulna', 'Sylhet', 'Barisal', 'Rangpur', 'Mymensingh'];
    List<String> sampleDistricts = ['Dhaka District', 'Gazipur', 'Narayanganj', 'Tangail', 'Kishoreganj'];
    List<String> sampleUpazilas = ['Savar', 'Dhamrai', 'Keraniganj', 'Nawabganj', 'Dohar'];
    List<String> sampleUnions = ['Union 1', 'Union 2', 'Union 3', 'Union 4', 'Union 5'];
    
    String randomArea = '';
    
    if (areaType == 'bangladesh') {
      randomArea = sampleDivisions[DateTime.now().millisecond % sampleDivisions.length];
    } else if (areaType == 'division') {
      randomArea = sampleDistricts[DateTime.now().millisecond % sampleDistricts.length];
    } else if (areaType == 'district') {
      randomArea = sampleUpazilas[DateTime.now().millisecond % sampleUpazilas.length];
    } else if (areaType == 'upazilla') {
      randomArea = sampleUnions[DateTime.now().millisecond % sampleUnions.length];
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('এলাকা নির্বাচন'),
        content: Text('$randomArea এলাকাতে যেতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('না'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAreaTap(randomArea);
            },
            child: Text('হ্যাঁ'),
          ),
        ],
      ),
    );
  }
}