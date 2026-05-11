import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fleet Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Performance insights, cost analysis, and trends', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                onPressed: () {}, 
                icon: const Icon(LucideIcons.calendar, size: 14), 
                label: const Text('This Month')
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildKpis(),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('Detailed charts will be rendered here. (FlChart integration ready)', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKpis() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Total Revenue Generated', '₹1.2Cr', 'up 12%', AppTheme.primaryBlue),
        _kpiCard('Operating Cost per km', '₹42.50', 'down 2%', AppTheme.success),
        _kpiCard('Fleet Utilization', '84%', 'target 85%', Colors.deepPurple),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
