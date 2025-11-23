import 'package:latlong2/latlong.dart';

class GeoFeature {
  final String id;
  final String name;
  final String adminLevel;
  final String? parentName;
  final List<List<LatLng>> polygons;

  GeoFeature({
    required this.id,
    required this.name,
    required this.adminLevel,
    required this.parentName,
    required this.polygons,
  });
}
