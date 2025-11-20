import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/person_model.dart';
import '../models/geo_model.dart';

class JsonService {
  // Persons data load
  static Future<List<Person>> loadPersonsData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/persons.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      print('Error loading persons data: $e');
      return [];
    }
  }

  // GeoJSON data load
  static Future<GeoJsonData> loadGeoJson(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return GeoJsonData.fromJson(jsonData);
    } catch (e) {
      print('Error loading geo data from $assetPath: $e');
      throw e;
    }
  }

  // Political party statistics calculation
  static Map<String, int> calculatePartyStats(List<Person> persons, String areaType, String areaName) {
    Map<String, int> stats = {};
    
    for (var person in persons) {
      bool matchesArea = false;
      
      switch (areaType) {
        case 'division':
          matchesArea = person.additionalInfo.division == areaName;
          break;
        case 'district':
          matchesArea = person.additionalInfo.district == areaName;
          break;
        case 'upazilla':
          matchesArea = person.additionalInfo.upazilla == areaName;
          break;
        case 'union':
          matchesArea = person.additionalInfo.union == areaName;
          break;
      }
      
      if (matchesArea) {
        String party = person.collectionInfo.supporter;
        stats[party] = (stats[party] ?? 0) + 1;
      }
    }
    Map<String, int> orderedStats = {};
    List<String> orderedParties = ['Jamaat-e-Islami', 'BNP', 'Jatiya Party', 'Awami League', 'Other'];
    
    for (String party in orderedParties) {
      orderedStats[party] = stats[party] ?? 0;
    }
      
    return stats;
  }

  // Get unique areas
  static List<String> getUniqueAreas(List<Person> persons, String areaType) {
    Set<String> areas = {};
    
    for (var person in persons) {
      switch (areaType) {
        case 'division':
          if (person.additionalInfo.division.isNotEmpty) {
            areas.add(person.additionalInfo.division);
          }
          break;
        case 'district':
          if (person.additionalInfo.district.isNotEmpty) {
            areas.add(person.additionalInfo.district);
          }
          break;
        case 'upazilla':
          if (person.additionalInfo.upazilla.isNotEmpty) {
            areas.add(person.additionalInfo.upazilla);
          }
          break;
        case 'union':
          if (person.additionalInfo.union.isNotEmpty) {
            areas.add(person.additionalInfo.union);
          }
          break;
      }
    }
    
    return areas.toList()..sort();
  }
    // Get area name from properties
  static String getAreaName(Map<String, dynamic> properties, String areaType) {
    switch (areaType) {
      case 'division':
        return properties['ADM1_EN'] ?? properties['division'] ?? 'Unknown';
      case 'district':
        return properties['ADM2_EN'] ?? properties['district'] ?? 'Unknown';
      case 'upazilla':
        return properties['ADM3_EN'] ?? properties['upazila'] ?? 'Unknown';
      case 'union':
        return properties['ADM4_EN'] ?? properties['union'] ?? 'Unknown';
      default:
        return properties['name'] ?? 'Unknown';
    }
  }
}
