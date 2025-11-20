import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../services/json_service.dart';

class DataTablePage extends StatefulWidget {
  final List<Person> persons;
  final String areaType;
  final String areaName;

  const DataTablePage({
    super.key,
    required this.persons,
    required this.areaType,
    required this.areaName,
  });

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  List<Person> filteredPersons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filterPersons();
  }

  void filterPersons() {
    setState(() {
      filteredPersons = widget.persons.where((person) {
        switch (widget.areaType) {
          case 'division':
            return person.additionalInfo.division == widget.areaName;
          case 'district':
            return person.additionalInfo.district == widget.areaName;
          case 'upazilla':
            return person.additionalInfo.upazilla == widget.areaName;
          case 'union':
            return person.additionalInfo.union == widget.areaName;
          case 'bangladesh':
            return true;
          default:
            return false;
        }
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('লোড হচ্ছে...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.areaName} - ডেটা টেবিল'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          // Statistics Card
          Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('মোট ভোটার', filteredPersons.length.toString()),
                  _buildStatCard('আওয়ামী লীগ', 
                    _countSupporters('Awami League').toString()),
                  _buildStatCard('বিএনপি', 
                    _countSupporters('BNP').toString()),
                ],
              ),
            ),
          ),

          // Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('নাম')),
                    DataColumn(label: Text('ভোটার নং')),
                    DataColumn(label: Text('বিভাগ')),
                    DataColumn(label: Text('জেলা')),
                    DataColumn(label: Text('উপজেলা')),
                    DataColumn(label: Text('দল')),
                    DataColumn(label: Text('পেশা')),
                  ],
                  rows: filteredPersons.map((person) {
                    return DataRow(cells: [
                      DataCell(Text(person.nameBn)),
                      DataCell(Text(person.voterNo)),
                      DataCell(Text(person.additionalInfo.division)),
                      DataCell(Text(person.additionalInfo.district)),
                      DataCell(Text(person.additionalInfo.upazilla)),
                      DataCell(
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getPartyColor(person.collectionInfo.supporter),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            person.collectionInfo.supporter,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      DataCell(Text(person.occupation)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  int _countSupporters(String party) {
    return filteredPersons
        .where((person) => person.collectionInfo.supporter == party)
        .length;
  }

  Color _getPartyColor(String party) {
    switch (party) {
      case 'Jamaat-e-Islami':
        return Colors.purple;
      case 'BNP':
        return Colors.red;
      case 'Jatiya Party':
        return Colors.blue;
      case 'Awami League':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}