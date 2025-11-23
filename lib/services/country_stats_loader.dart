// lib/services/country_stats_loader.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/country_stat.dart';

class CountryStatsLoader {
  static Future<List<CountryStat>> load(String path) async {
    final raw = await rootBundle.loadString(path);
    final List<dynamic> data = json.decode(raw);

    return data
        .map((e) => CountryStat.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
