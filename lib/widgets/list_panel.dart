import 'package:flutter/material.dart';
import '../models/geo_feature.dart';
import '../models/person.dart';

class ListPanel extends StatelessWidget {
  final String title;
  final List<GeoFeature> items;
  final List<Person>? persons;
  final Function(GeoFeature) onSelect;

  const ListPanel({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
    this.persons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: persons != null
              ? _buildPersonList()
              : _buildGeoList(),
        ),
      ],
    );
  }

  Widget _buildGeoList() {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) {
        return ListTile(
          title: Text(items[i].name),
          onTap: () => onSelect(items[i]),
        );
      },
    );
  }

  Widget _buildPersonList() {
    return ListView.builder(
      itemCount: persons!.length,
      itemBuilder: (_, i) {
        return ListTile(
          title: Text(persons![i].name),
          subtitle: Text(
            "${persons![i].division} > ${persons![i].district} > ${persons![i].upazila} > ${persons![i].union}",
          ),
        );
      },
    );
  }
}
