import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/engine.dart';
import '../core/theme.dart';

import 'package:fl_chart/fl_chart.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Driver? _detailDriver;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();
    final drivers = engine.drivers;
    final sortedDrivers = List<Driver>.from(drivers)..sort((a, b) => b.score.compareTo(a.score));
    final atRisk = drivers.where((d) => d.score < 60).toList();
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _detailDriver != null 
        ? _DriverDetailDrawer(
            driver: _detailDriver!, 
            onClose: () => Navigator.pop(context),
            onDeactivate: () {
              engine.deactivateDriver(_detailDriver!.id);
              Navigator.pop(context);
            },
          ) 
        : null,
      body: SingleChildScrollView(
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
                    Text('Driver Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Performance scores, compliance & licensing', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                  onPressed: () => _showDriverForm(context, engine), 
                  icon: const Icon(LucideIcons.plus, size: 14), 
                  label: const Text('Add Driver')
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildKpis(drivers),
            const SizedBox(height: 16),
            _buildLeaderboardTable(context, sortedDrivers),
            const SizedBox(height: 16),
            _buildCoachingSuggestions(atRisk),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(List<Driver> drivers) {
    int onDuty = drivers.where((d) => d.status == 'on_duty' && d.isActive).length;
    int atRisk = drivers.where((d) => d.score < 60 && d.isActive).length;
    int avgScore = drivers.isEmpty ? 0 : drivers.map((d) => d.score).reduce((a, b) => a + b) ~/ drivers.length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Total Drivers', '${drivers.length}', 'enrolled', AppTheme.primaryBlue),
        _kpiCard('On Duty Now', '$onDuty', 'active', AppTheme.success),
        _kpiCard('Fleet Avg Score', '$avgScore/100', 'live', Colors.deepPurple),
        _kpiCard('At-Risk Drivers', '$atRisk', 'score < 60', AppTheme.danger),
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

  Widget _buildLeaderboardTable(BuildContext context, List<Driver> drivers) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          columns: const [
            DataColumn(label: Text('Rank')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Score')),
            DataColumn(label: Text('Mileage')),
            DataColumn(label: Text('Trips')),
          ],
          rows: drivers.asMap().entries.map((entry) {
            final index = entry.key;
            final d = entry.value;
            return DataRow(cells: [
              DataCell(Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(d.name)),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: (d.score >= 75 ? AppTheme.success : d.score >= 55 ? AppTheme.warning : AppTheme.danger).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text('${d.score}', style: TextStyle(color: d.score >= 75 ? AppTheme.success : d.score >= 55 ? AppTheme.warning : AppTheme.danger, fontWeight: FontWeight.bold)),
              )),
              DataCell(Text('${d.mil.toStringAsFixed(1)} km/L')),
              DataCell(Text('${d.trips}')),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCoachingSuggestions(List<Driver> atRisk) {
    if (atRisk.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 16),
                SizedBox(width: 8),
                Text('Driver Coaching Suggestions', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...atRisk.map((d) {
              String suggestion = 'Needs general coaching.';
              if (d.overSpeed > 5) {
                suggestion = 'Focus on speed control.';
              } else if (d.idle > 20) {
                suggestion = 'Focus on idle reduction.';
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: AppTheme.danger),
                    const SizedBox(width: 8),
                    Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Text('—'),
                    const SizedBox(width: 8),
                    Text(suggestion, style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(4)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

  void _showDriverForm(BuildContext context, DataEngine engine, {Driver? d}) {
    final name = TextEditingController(text: d?.name ?? '');
    final phone = TextEditingController(text: d?.phone ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(d == null ? 'Add New Driver' : 'Edit Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (d == null) {
                engine.addDriver(Driver(
                  id: 'DRV-${1000 + engine.drivers.length + 1}', name: name.text, phone: phone.text,
                  age: 30, exp: 5, lic: 'NEW12345', licExp: '2030-01-01', blood: 'B+', vehicle: '', status: 'idle',
                  score: 100, mil: 0, idle: 0, trips: 0, harsh: 0, overSpeed: 0, deviation: 0, fuelEff: 100,
                  rating: 5.0, home: 'N/A', onLeave: false
                ));
              } else {
                engine.updateDriver(d.copyWith());
              }
              Navigator.pop(context);
            }, 
            child: const Text('Save')
          ),
        ],
      ),
    );
  }
}

class _DriverDetailDrawer extends StatelessWidget {
  final Driver driver;
  final VoidCallback onClose;
  final VoidCallback onDeactivate;

  const _DriverDetailDrawer({required this.driver, required this.onClose, required this.onDeactivate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 450,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            color: AppTheme.primaryBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(driver.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
                Text('${driver.id} • ${driver.exp} years experience', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Badge(label: driver.isActive ? driver.status.replaceAll('_', ' ').toUpperCase() : 'INACTIVE', color: driver.isActive ? AppTheme.success : AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    _Badge(label: 'Score: ${driver.score}', color: driver.score >= 75 ? AppTheme.success : AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('BEHAVIOUR ANALYSIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: RadarChart(
                    RadarChartData(
                      dataSets: [
                        RadarDataSet(
                          fillColor: AppTheme.primaryBlue.withOpacity(0.2),
                          borderColor: AppTheme.primaryBlue,
                          entryRadius: 3,
                          dataEntries: [
                            RadarEntry(value: driver.fuelEff.toDouble()),
                            RadarEntry(value: (100 - driver.idle)),
                            RadarEntry(value: (100 - driver.harsh * 10).clamp(0, 100).toDouble()),
                            RadarEntry(value: (100 - driver.overSpeed * 10).clamp(0, 100).toDouble()),
                            RadarEntry(value: (100 - driver.deviation * 20).clamp(0, 100).toDouble()),
                          ],
                        ),
                      ],
                      radarBackgroundColor: Colors.transparent,
                      borderData: FlBorderData(show: false),
                      radarBorderData: const BorderSide(color: Colors.transparent),
                      titlePositionPercentageOffset: 0.2,
                      titleTextStyle: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      getTitle: (index, angle) {
                        switch (index) {
                          case 0: return const RadarChartTitle(text: 'Fuel Eff');
                          case 1: return const RadarChartTitle(text: 'Idling');
                          case 2: return const RadarChartTitle(text: 'Safety');
                          case 3: return const RadarChartTitle(text: 'Speed');
                          case 4: return const RadarChartTitle(text: 'Route');
                          default: return const RadarChartTitle(text: '');
                        }
                      },
                      tickCount: 1,
                      ticksTextStyle: const TextStyle(color: Colors.transparent),
                      gridBorderData: const BorderSide(color: Color(0xFFe2e8f0), width: 1),
                    ),
                  ),
                ),
                const Divider(height: 48),
                const Text('DRIVER INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                _InfoRow(label: 'Phone', value: driver.phone, icon: LucideIcons.phone),
                _InfoRow(label: 'License No', value: driver.lic, icon: LucideIcons.creditCard),
                _InfoRow(label: 'License Expiry', value: driver.licExp, icon: LucideIcons.calendar, color: DateTime.parse(driver.licExp).difference(DateTime.now()).inDays < 60 ? AppTheme.danger : null),
                _InfoRow(label: 'Blood Group', value: driver.blood, icon: LucideIcons.droplets),
                _InfoRow(label: 'Home Town', value: driver.home, icon: LucideIcons.home),
                const Divider(height: 48),
                const Text('RECENT TRIPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                if (driver.tripHistory.isEmpty)
                  const Text('No recent trip history.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))
                else
                  ...driver.tripHistory.map((t) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${t.from} → ${t.to}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text('${t.date} • ${t.distance} km', style: const TextStyle(fontSize: 11)),
                    trailing: Text('${t.score}', style: TextStyle(color: t.score >= 80 ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.bold)),
                  )),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: onDeactivate, 
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                  child: const Text('Deactivate Driver')
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _InfoRow({required this.label, required this.value, required this.icon, this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
