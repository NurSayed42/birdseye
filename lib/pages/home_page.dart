import 'package:flutter/material.dart';
import '../services/json_service.dart';
import '../models/person_model.dart';
import '../models/geo_model.dart';
import '../widgets/bangladesh_map_widget.dart';
import '../widgets/political_party_stats_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Person> persons = [];
  GeoJsonData? bangladeshGeo;
  GeoJsonData? divisionsGeo;
  bool isLoading = true;
  String selectedAreaType = 'bangladesh';
  String selectedAreaName = 'Bangladesh';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedPersons = await JsonService.loadPersonsData();
      final loadedBangladeshGeo = await JsonService.loadGeoJson('assets/data/bangladesh_geo.json');
      final loadedDivisionsGeo = await JsonService.loadGeoJson('assets/data/divisions_geo.json');
      
      setState(() {
        persons = loadedPersons;
        bangladeshGeo = loadedBangladeshGeo;
        divisionsGeo = loadedDivisionsGeo;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        persons = [];
        bangladeshGeo = GeoJsonData(type: "FeatureCollection", features: []);
        divisionsGeo = GeoJsonData(type: "FeatureCollection", features: []);
        isLoading = false;
      });
    }
  }

  void handleAreaTap(String areaType, String areaName) {
    setState(() {
      selectedAreaType = areaType;
      selectedAreaName = areaName;
    });
  }

  void handleMapAreaTap(String areaName) {
    if (selectedAreaType == 'bangladesh') {
      // বাংলাদেশ ম্যাপ থেকে বিভাগ সিলেক্ট
      setState(() {
        selectedAreaType = 'division';
        selectedAreaName = areaName;
      });
    } else if (selectedAreaType == 'division') {
      // বিভাগ ম্যাপ থেকে জেলা সিলেক্ট
      setState(() {
        selectedAreaType = 'district';
        selectedAreaName = areaName;
      });
    } else if (selectedAreaType == 'district') {
      // জেলা ম্যাপ থেকে উপজেলা সিলেক্ট
      setState(() {
        selectedAreaType = 'upazilla';
        selectedAreaName = areaName;
      });
    } else if (selectedAreaType == 'upazilla') {
      // উপজেলা ম্যাপ থেকে ইউনিয়ন সিলেক্ট
      setState(() {
        selectedAreaType = 'union';
        selectedAreaName = areaName;
      });
    }
  }

  GeoJsonData? _getCurrentGeoData() {
    switch (selectedAreaType) {
      case 'division':
        return _getFilteredDivisionGeoData();
      case 'district':
        // district geo data থাকলে load করুন
        return divisionsGeo; // Placeholder
      case 'upazilla':
        // upazilla geo data থাকলে load করুন  
        return divisionsGeo; // Placeholder
      case 'union':
        // union geo data থাকলে load করুন
        return divisionsGeo; // Placeholder
      default:
        return bangladeshGeo;
    }
  }

  GeoJsonData _getFilteredDivisionGeoData() {
    if (divisionsGeo == null) {
      return GeoJsonData(type: "FeatureCollection", features: []);
    }

    // শুধু selected division-এর features filter করুন
    List<GeoFeature> filteredFeatures = divisionsGeo!.features.where((feature) {
      final properties = feature.properties;
      final featureName = properties['name'] ?? properties['ADM1_EN'] ?? '';
      return featureName == selectedAreaName;
    }).toList();

    return GeoJsonData(
      type: "FeatureCollection",
      features: filteredFeatures,
    );
  }

  Widget _buildBackButton() {
    if (selectedAreaType == 'bangladesh') {
      return SizedBox.shrink(); // বাংলাদেশ লেভেলে Back button দেখাবে না
    }

    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(Icons.arrow_back),
        title: Text('পিছনে যান'),
        trailing: Text(
          selectedAreaType == 'division' ? 'বাংলাদেশ' :
          selectedAreaType == 'district' ? 'বিভাগ' :
          selectedAreaType == 'upazilla' ? 'জেলা' : 'উপজেলা',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          setState(() {
            if (selectedAreaType == 'division') {
              selectedAreaType = 'bangladesh';
              selectedAreaName = 'Bangladesh';
            } else if (selectedAreaType == 'district') {
              selectedAreaType = 'division';
              // পূর্বের বিভাগ নাম রাখতে চাইলে এখানে logic add করুন
            } else if (selectedAreaType == 'upazilla') {
              selectedAreaType = 'district';
            } else if (selectedAreaType == 'union') {
              selectedAreaType = 'upazilla';
            }
          });
        },
      ),
    );
  }

  Widget _buildAreaInfo() {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAreaName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  selectedAreaType == 'bangladesh' ? 'জাতীয় পর্যায়' :
                  selectedAreaType == 'division' ? 'বিভাগীয় পর্যায়' :
                  selectedAreaType == 'district' ? 'জেলা পর্যায়' :
                  selectedAreaType == 'upazilla' ? 'উপজেলা পর্যায়' : 'ইউনিয়ন পর্যায়',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Chip(
              label: Text(
                selectedAreaType == 'bangladesh' ? 'জাতীয়' :
                selectedAreaType == 'division' ? 'বিভাগ' :
                selectedAreaType == 'district' ? 'জেলা' :
                selectedAreaType == 'upazilla' ? 'উপজেলা' : 'ইউনিয়ন',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('ডেটা লোড হচ্ছে...'),
            ],
          ),
        ),
      );
    }

    final currentGeoData = _getCurrentGeoData();

    return Scaffold(
      appBar: AppBar(
        title: Text('বাংলাদেশ পলিটিক্যাল ম্যাপ'),
        backgroundColor: Colors.green[700],
        actions: [
          if (selectedAreaType != 'bangladesh')
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  selectedAreaType = 'bangladesh';
                  selectedAreaName = 'Bangladesh';
                });
              },
              tooltip: 'সমস্ত বাংলাদেশ দেখুন',
            ),
        ],
      ),
      body: Column(
        children: [
          // Back Button (যদি বাংলাদেশে না থাকে)
          _buildBackButton(),

          // Area Information
          _buildAreaInfo(),

          // Map Section
          Expanded(
            flex: 3,
            child: Card(
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      selectedAreaType == 'bangladesh' 
                          ? 'বাংলাদেশের মানচিত্র - বিভাগ সিলেক্ট করুন' 
                          : '$selectedAreaName - মানচিত্র',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: currentGeoData != null 
                        ? BangladeshMapWidget(
                            geoData: currentGeoData,
                            persons: persons,
                            areaType: selectedAreaType,
                            areaName: selectedAreaName,
                            onAreaTap: handleMapAreaTap,
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text('মানচিত্র ডেটা লোড করতে সমস্যা হচ্ছে'),
                              ],
                            ),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      selectedAreaType == 'bangladesh' 
                          ? 'কোন বিভাগে ক্লিক করে বিস্তারিত দেখুন'
                          : 'ম্যাপে ক্লিক করে পরবর্তী লেভেলে যান',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistics Section
          Expanded(
            flex: 2,
            child: Card(
              margin: EdgeInsets.all(8),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      '$selectedAreaName - রাজনৈতিক দলের সমর্থক পরিসংখ্যান',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: PoliticalPartyStatsWidget(
                      persons: persons,
                      areaType: selectedAreaType,
                      areaName: selectedAreaName,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Info
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('মোট ভোটার', 
                  JsonService.calculatePartyStats(persons, selectedAreaType, selectedAreaName)
                    .values.fold(0, (sum, count) => sum + count).toString()),
                _buildInfoItem('জামাত-ই-ইসলামী', 
                  JsonService.calculatePartyStats(persons, selectedAreaType, selectedAreaName)['Jamaat-e-Islami']?.toString() ?? '0'),
                _buildInfoItem('বিএনপি', 
                  JsonService.calculatePartyStats(persons, selectedAreaType, selectedAreaName)['BNP']?.toString() ?? '0'),
                _buildInfoItem('আওয়ামী লীগ', 
                  JsonService.calculatePartyStats(persons, selectedAreaType, selectedAreaName)['Awami League']?.toString() ?? '0'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
        ),
      ],
    );
  }
}