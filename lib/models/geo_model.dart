class GeoFeature {
  final String type;
  final GeoGeometry geometry;
  final Map<String, dynamic> properties;

  GeoFeature({
    required this.type,
    required this.geometry,
    required this.properties,
  });

  factory GeoFeature.fromJson(Map<String, dynamic> json) {
    return GeoFeature(
      type: json['type'],
      geometry: GeoGeometry.fromJson(json['geometry']),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
    );
  }
}

class GeoGeometry {
  final String type;
  final dynamic coordinates;

  GeoGeometry({
    required this.type,
    required this.coordinates,
  });

  factory GeoGeometry.fromJson(Map<String, dynamic> json) {
    return GeoGeometry(
      type: json['type'],
      coordinates: json['coordinates'],
    );
  }
}

class GeoJsonData {
  final String type;
  final List<GeoFeature> features;

  GeoJsonData({
    required this.type,
    required this.features,
  });

  factory GeoJsonData.fromJson(Map<String, dynamic> json) {
    var features = (json['features'] as List)
        .map((feature) => GeoFeature.fromJson(feature))
        .toList();
    
    return GeoJsonData(
      type: json['type'],
      features: features,
    );
  }
}