import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/engine.dart';
import '../core/theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'all'; // all, critical, warnings
  AlertCategory? _categoryFilter;

  bool _whatsappEnabled = true;
  bool _smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();
    
    // Filter alerts based on status (exclude dismissed) and category/severity
    final activeAlerts = engine.alerts.where((a) => a.status != AlertStatus.dismissed).toList();
    
    final filteredAlerts = activeAlerts.where((a) {
      bool categoryMatch = _categoryFilter == null || a.category == _categoryFilter;
      bool severityMatch = _filter == 'all' || 
                          (_filter == 'critical' && a.sev == 'danger') || 
                          (_filter == 'warnings' && a.sev == 'warning');
      return categoryMatch && severityMatch;
    }).toList();

    int critical = activeAlerts.where((a) => a.sev == 'danger').length;
    int warning = activeAlerts.where((a) => a.sev == 'warning').length;

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
                  Text('Alerts & Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Real-time system events and actionable insights', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => engine.dismissAllAlerts(),
                    icon: const Icon(LucideIcons.trash2, size: 14),
                    label: const Text('Clear All'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
                    onPressed: () => engine.dismissAllAlerts(), // Simulating acknowledge all
                    icon: const Icon(LucideIcons.checkCheck, size: 14), 
                    label: const Text('Mark All Read')
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationSettings(),
          const SizedBox(height: 16),
          _buildKpis(activeAlerts.length, critical, warning),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          _buildAlertsList(engine, filteredAlerts),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1))),
      child: Row(
        children: [
          const Icon(LucideIcons.bellRing, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          const Expanded(child: Text('Notification Delivery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          _toggle('WhatsApp', _whatsappEnabled, (v) => setState(() => _whatsappEnabled = v)),
          const SizedBox(width: 16),
          _toggle('SMS', _smsEnabled, (v) => setState(() => _smsEnabled = v)),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryBlue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(label: const Text('All'), selected: _filter == 'all', onSelected: (s) => setState(() => _filter = 'all')),
        FilterChip(label: const Text('Critical'), selected: _filter == 'critical', onSelected: (s) => setState(() => _filter = 'critical')),
        FilterChip(label: const Text('Warnings'), selected: _filter == 'warnings', onSelected: (s) => setState(() => _filter = 'warnings')),
        const SizedBox(width: 16),
        ...AlertCategory.values.map((cat) => FilterChip(
          label: Text(cat.name.toUpperCase()),
          selected: _categoryFilter == cat,
          onSelected: (s) => setState(() => _categoryFilter = s ? cat : null),
          selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
        )),
      ],
    );
  }

  Widget _buildKpis(int total, int critical, int warning) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Active Alerts', '$total', 'total unresolved', AppTheme.primaryBlue),
        _kpiCard('Critical Priority', '$critical', 'immediate action', AppTheme.danger),
        _kpiCard('Warnings', '$warning', 'monitor closely', AppTheme.warning),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 150,
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

  Widget _buildAlertsList(DataEngine engine, List<Alert> alerts) {
    if (alerts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(LucideIcons.shieldCheck, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('No active alerts matching criteria', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: alerts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final a = alerts[index];
          final color = a.sev == 'danger' ? AppTheme.danger : AppTheme.warning;
          
          IconData icon;
          switch (a.category) {
            case AlertCategory.safety: icon = LucideIcons.shieldAlert; break;
            case AlertCategory.fuel: icon = LucideIcons.fuel; break;
            case AlertCategory.compliance: icon = LucideIcons.fileWarning; break;
            case AlertCategory.connectivity: icon = LucideIcons.wifiOff; break;
          }

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(a.truck, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(a.sev.toUpperCase(), style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
                ),
                if (a.status == AlertStatus.acknowledged)
                  const Icon(LucideIcons.checkCircle, color: AppTheme.success, size: 14),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(a.msg, style: TextStyle(fontSize: 13, color: a.status == AlertStatus.acknowledged ? AppTheme.textSecondary : AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(a.time, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
            trailing: a.status == AlertStatus.pending 
              ? TextButton(
                  onPressed: () => engine.acknowledgeAlert(a.id),
                  child: const Text('Acknowledge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              : const Text('Acknowledged', style: TextStyle(fontSize: 11, color: AppTheme.success)),
          );
        },
      ),
    );
  }
}
