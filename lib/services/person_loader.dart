import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/person.dart';

class PersonLoader {
  static Future<List<Person>> loadPersons() async {
    final raw = await rootBundle.loadString("assets/persons.json");
    final list = jsonDecode(raw) as List;

    return list.map((p) => Person.fromJson(p)).toList();
  }
}
