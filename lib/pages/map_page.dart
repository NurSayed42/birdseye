import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/geo_feature.dart';
import '../models/person.dart';
import '../services/geo_loader.dart';
import '../services/person_loader.dart';
import '../widgets/list_panel.dart';

enum Level { country, division, district, upazila, union }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController controller = MapController();

  // geo lists
  List<GeoFeature> divisions = [];
  List<GeoFeature> districts = [];
  List<GeoFeature> upazilas = [];
  List<GeoFeature> unions = [];

  List<Person> persons = [];

  // selected items
  GeoFeature? selectedDivision;
  GeoFeature? selectedDistrict;
  GeoFeature? selectedUpazila;
  GeoFeature? selectedUnion;

  Level level = Level.country;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAll();
  }

  Future<void> loadAll() async {
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

    setState(() => loading = false);
  }

  // ------------------ BUILD UI ------------------

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
            onPressed: () {
              setState(() {
                level = Level.country;
                selectedDivision = null;
                selectedDistrict = null;
                selectedUpazila = null;
                selectedUnion = null;
              });
            },
            icon: const Icon(Icons.home),
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 3, child: buildMap()),
          Expanded(flex: 2, child: buildSideList()),
        ],
      ),
    );
  }

  // ------------------- MAP -------------------

  Widget buildMap() {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: const LatLng(23.7, 90.4),
        initialZoom: 7,
        maxZoom: 14,
      ),
      children: [
        TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
        PolygonLayer(polygons: polygonsForLevel()),
      ],
    );
  }

  List<Polygon> polygonsForLevel() {
    List<GeoFeature> list = [];

    if (level == Level.country) list = divisions;
    if (level == Level.division && selectedDivision != null) {
      list = divisions.where((d) => d.name == selectedDivision!.name).toList();
    }
    if (level == Level.district && selectedDistrict != null) {
      list = districts.where((d) => d.name == selectedDistrict!.name).toList();
    }
    if (level == Level.upazila && selectedUpazila != null) {
      list = upazilas.where((u) => u.name == selectedUpazila!.name).toList();
    }
    if (level == Level.union && selectedUnion != null) {
      list = unions.where((u) => u.name == selectedUnion!.name).toList();
    }

    return list
        .expand((f) => f.polygons.map(
              (ring) => Polygon(
                points: ring,
                color: Colors.green.withOpacity(0.4),
                borderColor: Colors.black,
                borderStrokeWidth: 1.0,
              ),
            ))
        .toList();
  }

  void onPolygonTap(GeoFeature f) {
    setState(() {
      if (level == Level.country) {
        selectedDivision = f;
        level = Level.division;
      }
    });
  }

  // ------------------- RIGHT LIST -------------------

  Widget buildSideList() {
    if (level == Level.country) {
      return ListPanel(
        title: "Divisions",
        items: divisions,
        onSelect: (f) {
          setState(() {
            selectedDivision = f;
            level = Level.division;
          });
        },
      );
    }

    if (level == Level.division) {
      final list = districts
          .where((d) => d.parentName == selectedDivision!.name)
          .toList();

      return ListPanel(
        title: "Districts",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedDistrict = f;
            level = Level.district;
          });
        },
      );
    }

    if (level == Level.district) {
      final list = upazilas
          .where((u) => u.parentName == selectedDistrict!.name)
          .toList();

      return ListPanel(
        title: "Upazilas",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedUpazila = f;
            level = Level.upazila;
          });
        },
      );
    }

    if (level == Level.upazila) {
      final list = unions
          .where((u) => u.parentName == selectedUpazila!.name)
          .toList();

      return ListPanel(
        title: "Unions",
        items: list,
        onSelect: (f) {
          setState(() {
            selectedUnion = f;
            level = Level.union;
          });
        },
      );
    }

    // persons list
    if (level == Level.union) {
      final list = persons
          .where((p) => p.union == selectedUnion!.name)
          .toList();

      return ListPanel(
        title: "Persons in ${selectedUnion!.name}",
        items: const [],
        persons: list,
        onSelect: (_) {},
      );
    }

    return const SizedBox();
  }
}
