import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Automated Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Download and schedule compliance and performance reports', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          _buildReportItem('Daily Fleet Summary', 'Includes distance covered, fuel consumed, and active vehicles.', LucideIcons.fileText),
          _buildReportItem('Driver Compliance Report', 'Detailed view of license expiries, health scores, and leaves.', LucideIcons.userCheck),
          _buildReportItem('Monthly Fuel Audit', 'Complete ledger of all fill-ups across all stations.', LucideIcons.fuel),
          _buildReportItem('Expense & Toll Report', 'FASTag deductions, route tolls, and miscellaneous expenses.', LucideIcons.receipt),
        ],
      ),
    );
  }

  Widget _buildReportItem(String title, String desc, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.download, size: 14),
          label: const Text('Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.background,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
