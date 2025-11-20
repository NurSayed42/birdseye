class AppConstants {
  static const List<String> politicalParties = [
    'Jamaat-e-Islami',
    'BNP', 
    'Jatiya Party',
    'Awami League',
    'Other'
  ];

  static const Map<String, int> partyColors = {
    'Jamaat-e-Islami': 0xFF800080, // Purple
    'BNP': 0xFF8B0000,             // Red
    'Jatiya Party': 0xFF000080,    // Blue
    'Awami League': 0xFF006A4E,    // Green
    'Other': 0xFF808080,           // Gray
  };

  static const Map<String, String> geoJsonPaths = {
    'bangladesh': 'assets/data/bangladesh_geo.json',
    'divisions': 'assets/data/divisions_geo.json',
    'districts': 'assets/data/districts_geo.json',
    'upazilas': 'assets/data/upazilas_geo.json',
    'unions': 'assets/data/unions_geo.json',
  };
}