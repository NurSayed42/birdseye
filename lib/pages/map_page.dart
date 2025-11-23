import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geo_feature.dart';
import '../models/person.dart';
import '../models/country_stat.dart';
import '../services/geo_loader.dart';
import '../services/person_loader.dart';
import '../services/country_stats_loader.dart';
import '../widgets/list_panel.dart';

enum Level { country, division, district, upazila, union }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  // Scroll controllers for the stats table
  final ScrollController _verticalStatsController = ScrollController();
  final ScrollController _horizontalStatsController = ScrollController();

  // Geo lists
  List<GeoFeature> divisions = [];
  List<GeoFeature> districts = [];
  List<GeoFeature> upazilas = [];
  List<GeoFeature> unions = [];

  // Persons (union level list)
  List<Person> persons = [];

  // Political stats (CountryMap.json)
  List<CountryStat> regionStats = [];

  // Selected admin units
  GeoFeature? selectedDivision;
  GeoFeature? selectedDistrict;
  GeoFeature? selectedUpazila;
  GeoFeature? selectedUnion;

  Level level = Level.country;
  bool loading = true;

  // Sorting state
  String? sortParty; // internal key: "Jamaat Islami", "BNP", ...
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _verticalStatsController.dispose();
    _horizontalStatsController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // LOAD ALL DATA
  // -------------------------------------------------------------------
  Future<void> _loadInitialData() async {
    divisions = await GeoLoader.load(
      "assets/divisions_geo.json",
      adminLevel: "ADM1",
      nameKey: "ADM1_EN",
      parentKey: "ADM0_EN",
    );

    districts = await GeoLoader.load(
      "assets/districts_geo.json",
      adminLevel: "ADM2",
      nameKey: "ADM2_EN",
      parentKey: "ADM1_EN",
    );

    upazilas = await GeoLoader.load(
      "assets/upazilas_geo.json",
      adminLevel: "ADM3",
      nameKey: "ADM3_EN",
      parentKey: "ADM2_EN",
    );

    unions = await GeoLoader.load(
      "assets/unions_geo.json",
      adminLevel: "ADM4",
      nameKey: "ADM4_EN",
      parentKey: "ADM3_EN",
    );

    persons = await PersonLoader.loadPersons();

    // Political stats (একই CountryMap.json থেকে সব স্তর)
    regionStats = await CountryStatsLoader.load("assets/CountryMap.json");

    setState(() => loading = false);
  }

  // -------------------------------------------------------------------
  // RETURN STATS BASED ON CURRENT LEVEL
  // -------------------------------------------------------------------
  List<CountryStat> _statsForCurrentLevel() {
    List<CountryStat> result = [];

    // COUNTRY → show all divisions
    if (level == Level.country) {
      final divisionNames = divisions.map((d) => d.name).toSet();
      result =
          regionStats.where((s) => divisionNames.contains(s.name)).toList();
    }

    // DIVISION → show its districts
    else if (level == Level.division && selectedDivision != null) {
      final districtNames = districts
          .where((d) => d.parentName == selectedDivision!.name)
          .map((e) => e.name)
          .toSet();

      result =
          regionStats.where((s) => districtNames.contains(s.name)).toList();
    }

    // DISTRICT → show its upazilas
    else if (level == Level.district && selectedDistrict != null) {
      final upazilaNames = upazilas
          .where((u) => u.parentName == selectedDistrict!.name)
          .map((e) => e.name)
          .toSet();

      result =
          regionStats.where((s) => upazilaNames.contains(s.name)).toList();
    }

    // UPAZILA → show its unions
    else if (level == Level.upazila && selectedUpazila != null) {
      final unionNames = unions
          .where((u) => u.parentName == selectedUpazila!.name)
          .map((e) => e.name)
          .toSet();

      result =
          regionStats.where((s) => unionNames.contains(s.name)).toList();
    }

    // UNION → only that union (if stats exists)
    else if (level == Level.union && selectedUnion != null) {
      result =
          regionStats.where((s) => s.name == selectedUnion!.name).toList();
    }

    // ---------- SORTING ----------
    if (sortParty != null && sortParty!.isNotEmpty) {
      double getValue(CountryStat s, String partyName) {
        final p = s.parties.firstWhere(
          (x) => x.name.toLowerCase() == partyName.toLowerCase(),
          orElse: () => PartyStat(name: partyName, percentage: 0),
        );
        return p.percentage;
      }

      result.sort((a, b) {
        final av = getValue(a, sortParty!);
        final bv = getValue(b, sortParty!);
        return sortAscending ? av.compareTo(bv) : bv.compareTo(av);
      });
    } else {
      // default: area name ASC
      result.sort((a, b) => a.name.compareTo(b.name));
    }

    return result;
  }

  void _setSort(String partyName, bool asc) {
    setState(() {
      sortParty = partyName;
      sortAscending = asc;
    });
  }

  // -------------------------------------------------------------------
  // TABLE UI - FIXED VERSION
  // -------------------------------------------------------------------
  Widget _buildStatsTable(List<CountryStat> stats) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: const Text("No statistics available for this region."),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Political Statistics",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Horizontal scroll for table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FixedColumnWidth(120), // Area
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(100),
                3: FixedColumnWidth(100),
                4: FixedColumnWidth(100),
              },
              children: [
                // ------------ HEADER ROW ----------------
                TableRow(
                  children: [
                    _tableHeader("Area"),
                    _partyHeader("JI", Icons.flag),
                    _partyHeader("BNP", Icons.how_to_vote),
                    _partyHeader("IAB", Icons.mosque),
                    _partyHeader("NCP", Icons.groups),
                  ],
                ),

                // ------------ DATA ROWS ----------------
                ...stats.map((row) {
                  String getPercent(String partyName) {
                    final p = row.parties.firstWhere(
                      (x) => x.name.toLowerCase() == partyName.toLowerCase(),
                      orElse: () => PartyStat(name: partyName, percentage: 0),
                    );
                    return "${p.percentage.toStringAsFixed(1)}%";
                  }

                  return TableRow(
                    children: [
                      _tableCell(row.name),
                      _tableCell(getPercent("Jamaat Islami")),
                      _tableCell(getPercent("BNP")),
                      _tableCell(getPercent("Islami Andolon")),
                      _tableCell(getPercent("NCP")),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.blueGrey.shade200,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );

  // FIXED: Now shows party name properly
  Widget _partyHeader(String partyName, IconData icon) {
    final bool isActive = sortParty == partyName;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blueGrey.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            partyName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _setSort(partyName, true),
                child: Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: isActive && sortAscending
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _setSort(partyName, false),
                child: Icon(
                  Icons.arrow_downward,
                  size: 14,
                  color: isActive && !sortAscending
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text) => Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          text, 
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );

  // -------------------------------------------------------------------
  // MAIN UI BUILD - UPDATED LAYOUT
  // -------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("BD Map Navigation"),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              setState(() {
                level = Level.country;
                selectedDivision = null;
                selectedDistrict = null;
                selectedUpazila = null;
                selectedUnion = null;
                sortParty = null;
                sortAscending = false;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map takes most of the space
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Map area
                Expanded(
                  flex: 3,
                  child: _buildMap(),
                ),
                // Selection panel only (no stats table)
                Expanded(
                  flex: 2,
                  child: _buildSelectionPanel(),
                ),
              ],
            ),
          ),
          // Stats table at the bottom
          Container(
            height: 280,
            child: SingleChildScrollView(
              controller: _horizontalStatsController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalStatsController,
                scrollDirection: Axis.vertical,
                child: _buildStatsTable(_statsForCurrentLevel()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // MAP VIEW
  // -------------------------------------------------------------------
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(23.7, 90.4),
        initialZoom: 7,
        maxZoom: 14,
        onTap: (_, __) {},
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        PolygonLayer(polygons: _polygonsForLevel()),
      ],
    );
  }

  List<Polygon> _polygonsForLevel() {
    List<GeoFeature> list = [];

    if (level == Level.country) {
      list = divisions;
    } else if (level == Level.division && selectedDivision != null) {
      list = districts
          .where((d) => d.parentName == selectedDivision!.name)
          .toList();
    } else if (level == Level.district && selectedDistrict != null) {
      list = upazilas
          .where((u) => u.parentName == selectedDistrict!.name)
          .toList();
    } else if (level == Level.upazila && selectedUpazila != null) {
      list = unions
          .where((u) => u.parentName == selectedUpazila!.name)
          .toList();
    } else if (level == Level.union && selectedUnion != null) {
      list = unions
          .where((u) => u.name == selectedUnion!.name)
          .toList();
    }

    return list
        .expand(
          (f) => f.polygons.map(
            (ring) => Polygon(
              points: ring,
              color: Colors.green.withOpacity(0.4),
              borderColor: Colors.black,
              borderStrokeWidth: 1.0,
            ),
          ),
        )
        .toList();
  }

  // -------------------------------------------------------------------
  // RIGHT PANEL (ONLY SELECTION OPTIONS - NO STATS TABLE)
  // -------------------------------------------------------------------
  Widget _buildSelectionPanel() {
    // ------- Navigation list widget -------
    Widget listWidget = const SizedBox();

    if (level == Level.country) {
      listWidget = ListPanel(
        title: "Divisions",
        items: divisions,
        onSelect: (f) {
          setState(() {
            selectedDivision = f;
            level = Level.division;
            sortParty = null;
            sortAscending = false;
          });
        },
      );
    } else if (level == Level.division) {
      final list = districts
          .where((d) => d.parentName == selectedDivision!.name)
          .toList();

      listWidget = ListPanel(
        title: "Districts of ${selectedDivision!.name}",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedDistrict = f;
            level = Level.district;
            sortParty = null;
            sortAscending = false;
          });
        },
      );
    } else if (level == Level.district) {
      final list = upazilas
          .where((u) => u.parentName == selectedDistrict!.name)
          .toList();

      listWidget = ListPanel(
        title: "Upazilas of ${selectedDistrict!.name}",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedUpazila = f;
            level = Level.upazila;
            sortParty = null;
            sortAscending = false;
          });
        },
      );
    } else if (level == Level.upazila) {
      final list = unions
          .where((u) => u.parentName == selectedUpazila!.name)
          .toList();

      listWidget = ListPanel(
        title: "Unions of ${selectedUpazila!.name}",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedUnion = f;
            level = Level.union;
            sortParty = null;
            sortAscending = false;
          });
        },
      );
    } else if (level == Level.union) {
      final list =
          persons.where((p) => p.union == selectedUnion!.name).toList();

      listWidget = ListPanel(
        title: "Persons in ${selectedUnion!.name}",
        items: const [],
        persons: list,
        onSelect: (_) {},
      );
    }

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[700],
            child: Row(
              children: [
                Icon(Icons.list, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  _getPanelTitle(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // List content
          Expanded(child: listWidget),
        ],
      ),
    );
  }

  String _getPanelTitle() {
    switch (level) {
      case Level.country:
        return "Select Division";
      case Level.division:
        return "Districts in ${selectedDivision?.name ?? ''}";
      case Level.district:
        return "Upazilas in ${selectedDistrict?.name ?? ''}";
      case Level.upazila:
        return "Unions in ${selectedUpazila?.name ?? ''}";
      case Level.union:
        return "Persons in ${selectedUnion?.name ?? ''}";
    }
  }
}