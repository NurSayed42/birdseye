import 'package:flutter/material.dart';
import '../models/person_model.dart';
import '../services/json_service.dart';

class PoliticalPartyStatsWidget extends StatelessWidget {
  final List<Person> persons;
  final String areaType;
  final String areaName;

  const PoliticalPartyStatsWidget({
    super.key,
    required this.persons,
    required this.areaType,
    required this.areaName,
  });

  @override
  Widget build(BuildContext context) {
    final stats = JsonService.calculatePartyStats(persons, areaType, areaName);
    final total = stats.values.fold(0, (sum, count) => sum + count);

    if (stats.isEmpty || total == 0) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Changed to min
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'এই এলাকার জন্য কোন ডেটা পাওয়া যায়নি',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'এলাকা: $areaName',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // FIX: Changed from max to min
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[700]),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'রাজনৈতিক দলের পরিসংখ্যান',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    'মোট: $total',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue[700],
                ),
              ],
            ),
          ),

          // Percentage Chart - Mobile Optimized
          _buildMobilePercentageChart(stats, total),

          // Divider
          Divider(height: 1, thickness: 1),

          // Detailed List - Mobile Optimized
          Expanded( // FIX: Added Expanded to allow scrolling
            child: _buildMobileDetailedList(stats, total),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePercentageChart(Map<String, int> stats, int total) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'দলভিত্তিক শতকরা হার',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          
          // Horizontal Bar Chart
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            child: Row(
              children: _buildChartSegments(stats, total),
            ),
          ),
          SizedBox(height: 12),
          
          // Legend
          _buildChartLegend(stats, total),
        ],
      ),
    );
  }

  List<Widget> _buildChartSegments(Map<String, int> stats, int total) {
    List<Widget> segments = [];
    final entries = stats.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      double percentage = total > 0 ? (entry.value / total) : 0;
      if (percentage > 0) {
        segments.add(
          Expanded(
            flex: (percentage * 100).round(),
            child: Container(
              decoration: BoxDecoration(
                color: _getPartyColor(entry.key),
                borderRadius: _getSegmentBorderRadius(i == 0, i == entries.length - 1),
              ),
            ),
          ),
        );
      }
    }

    return segments;
  }

  BorderRadius _getSegmentBorderRadius(bool isFirst, bool isLast) {
    if (isFirst && isLast) {
      return BorderRadius.circular(12);
    } else if (isFirst) {
      return BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      );
    } else if (isLast) {
      return BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    }
    return BorderRadius.zero;
  }

  Widget _buildChartLegend(Map<String, int> stats, int total) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: stats.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(1) : '0.0';
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getPartyColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6),
            Flexible( // FIX: Added Flexible to prevent text overflow
              child: Text(
                '${entry.key} ($percentage%)',
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMobileDetailedList(Map<String, int> stats, int total) {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final party = stats.keys.elementAt(index);
        final count = stats.values.elementAt(index);
        final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getPartyColor(party),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              party,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '$count জন ভোটার',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getPartyColor(party).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getPartyColor(party).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getPartyColor(party),
                ),
              ),
            ),
          ),
        );
      },
    );
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
      case 'NCP':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}