// lib/models/country_stat.dart

class PartyStat {
  final String name;
  final double percentage;

  PartyStat({
    required this.name,
    required this.percentage,
  });

  factory PartyStat.fromJson(Map<String, dynamic> json) {
    return PartyStat(
      name: (json['name'] ?? '') as String,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CountryStat {
  final String name;
  final List<PartyStat> parties;

  CountryStat({
    required this.name,
    required this.parties,
  });

  factory CountryStat.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['parties'] as List<dynamic>? ?? [];
    final parties = list
        .map((p) => PartyStat.fromJson(p as Map<String, dynamic>))
        .toList();

    return CountryStat(
      name: (json['name'] ?? '') as String,
      parties: parties,
    );
  }
}
