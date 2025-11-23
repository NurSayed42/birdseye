import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../models/geo_feature.dart';

class GeoLoader {
  static Future<List<GeoFeature>> load(
    String path, {
    required String adminLevel,
    required String nameKey,
    required String? parentKey,
  }) async {
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);

    List features = decoded["features"];

    return features.map<GeoFeature>((f) {
      final props = f["properties"];
      final geom = f["geometry"];

      List<List<LatLng>> polygons = [];

      if (geom["type"] == "Polygon") {
        for (var ring in geom["coordinates"]) {
          polygons.add(_latLngRing(ring));
        }
      } else if (geom["type"] == "MultiPolygon") {
        for (var poly in geom["coordinates"]) {
          for (var ring in poly) {
            polygons.add(_latLngRing(ring));
          }
        }
      }

      return GeoFeature(
        id: f["id"].toString(),
        name: props[nameKey] ?? "",
        adminLevel: adminLevel,
        parentName: parentKey == null ? null : props[parentKey],
        polygons: polygons,
      );
    }).toList();
  }

  static List<LatLng> _latLngRing(List coords) {
    return coords.map<LatLng>((p) {
      return LatLng(p[1], p[0]); // GeoJSON = [lon, lat]
    }).toList();
  }
}
