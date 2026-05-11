import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/engine.dart';
import '../core/theme.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Vehicle? _detailVehicle;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();
    final vehicles = engine.vehicles;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _detailVehicle != null 
        ? _VehicleDetailDrawer(
            vehicle: _detailVehicle!, 
            onClose: () => Navigator.pop(context),
            onDeactivate: () {
              engine.deactivateVehicle(_detailVehicle!.plate);
              Navigator.pop(context);
            },
          ) 
        : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                bool isNarrow = constraints.maxWidth < 600;
                return Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isNarrow ? constraints.maxWidth : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Fleet Vehicles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('Manage and monitor all vehicles', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: isNarrow ? constraints.maxWidth : null,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: isNarrow ? WrapAlignment.start : WrapAlignment.end,
                        children: [
                          OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.download, size: 14), label: const Text('Export')),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                            onPressed: () => _showVehicleForm(context, engine), 
                            icon: const Icon(LucideIcons.plus, size: 14), 
                            label: const Text('Add Vehicle')
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 16),
            _buildKpis(vehicles),
            const SizedBox(height: 16),
            _buildVehicleTable(context, engine, vehicles),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(List<Vehicle> vehicles) {
    int running = vehicles.where((v) => v.status == 'running' && v.isActive).length;
    int idle = vehicles.where((v) => v.status == 'idle' && v.isActive).length;
    int alerts = vehicles.where((v) => v.alerts.isNotEmpty && v.isActive).length;
    int avgHealth = vehicles.isEmpty ? 0 : vehicles.map((v) => v.health).reduce((a, b) => a + b) ~/ vehicles.length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Total Fleet', '${vehicles.length}', 'vehicles', AppTheme.primaryBlue),
        _kpiCard('Running Now', '$running', 'of ${vehicles.length}', AppTheme.success),
        _kpiCard('Idle / Stopped', '$idle', 'parked', AppTheme.warning),
        _kpiCard('With Alerts', '$alerts', 'needs attention', AppTheme.danger),
        _kpiCard('Avg Health', '$avgHealth/100', 'score', Colors.deepPurple),
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

  Widget _buildVehicleTable(BuildContext context, DataEngine engine, List<Vehicle> vehicles) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          columns: const [
            DataColumn(label: Text('Reg. Plate')),
            DataColumn(label: Text('Status/Loc')),
            DataColumn(label: Text('Compliance')),
            DataColumn(label: Text('Health')),
            DataColumn(label: Text('Actions')),
          ],
          rows: vehicles.map((v) {
            bool isExpired = DateTime.now().isAfter(DateTime.parse(v.nextService));
            return DataRow(
              color: MaterialStateProperty.resolveWith((states) => v.isActive ? null : Colors.grey.shade100),
              cells: [
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(v.plate, style: TextStyle(fontWeight: FontWeight.bold, color: v.isActive ? AppTheme.primaryBlue : AppTheme.textSecondary)),
                  Text(v.model, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              )),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(v.isActive ? v.status.toUpperCase() : 'DEACTIVATED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: v.isActive ? (v.status == 'running' ? AppTheme.success : AppTheme.warning) : AppTheme.textSecondary)),
                  Text(v.loc, style: const TextStyle(fontSize: 11)),
                ],
              )),
              DataCell(Row(
                children: [
                  _CompIcon(icon: LucideIcons.shieldCheck, color: AppTheme.success, tooltip: 'Insurance Valid'),
                  _CompIcon(icon: LucideIcons.fileText, color: isExpired ? AppTheme.danger : AppTheme.success, tooltip: 'Service Due: ${v.nextService}'),
                ],
              )),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: (v.health > 70 ? AppTheme.success : AppTheme.warning).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('${v.health}%', style: TextStyle(color: v.health > 70 ? AppTheme.success : AppTheme.warning, fontWeight: FontWeight.bold, fontSize: 12)),
              )),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.eye, size: 18), 
                    onPressed: () {
                      setState(() => _detailVehicle = v);
                      _scaffoldKey.currentState?.openEndDrawer();
                    }
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit2, size: 18), 
                    onPressed: () => _showVehicleForm(context, engine, v: v)
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _showVehicleForm(BuildContext context, DataEngine engine, {Vehicle? v}) {
    final plate = TextEditingController(text: v?.plate ?? '');
    final model = TextEditingController(text: v?.model ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(v == null ? 'Add New Vehicle' : 'Edit Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: plate, decoration: const InputDecoration(labelText: 'Registration Plate (e.g. MH 01 AB 1234)')),
            TextField(controller: model, decoration: const InputDecoration(labelText: 'Vehicle Model (e.g. Tata Prima)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (v == null) {
                engine.addVehicle(Vehicle(
                  plate: plate.text, model: model.text, year: 2024, type: 'HCV', status: 'idle', driver: 'Unassigned',
                  loc: 'Depot', speed: 0, fuel: 100, mil: 0, idle: 0, fastag: 0, health: 100, odo: 0,
                  nextService: '2025-01-01', insurance: '2025-01-01', permit: '2025-01-01', puc: '2025-01-01',
                  lastFill: 'N/A', alerts: [], lat: 19.0760, lng: 72.8777
                ));
              } else {
                engine.updateVehicle(v.copyWith()); // Simplified update for demo
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

class _CompIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  const _CompIcon({required this.icon, required this.color, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _VehicleDetailDrawer extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onClose;
  final VoidCallback onDeactivate;

  const _VehicleDetailDrawer({required this.vehicle, required this.onClose, required this.onDeactivate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 400,
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
                    Text(vehicle.plate, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
                Text('${vehicle.model} • ${vehicle.type}', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Badge(label: vehicle.isActive ? vehicle.status.toUpperCase() : 'INACTIVE', color: vehicle.isActive ? AppTheme.success : AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    _Badge(label: 'Health: ${vehicle.health}%', color: vehicle.health > 70 ? AppTheme.success : AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('COMPLIANCE & DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                _ComplianceRow(label: 'Insurance', date: vehicle.insurance, status: 'Valid'),
                _ComplianceRow(label: 'PUC', date: vehicle.puc, status: 'Valid'),
                _ComplianceRow(label: 'Permit', date: vehicle.permit, status: 'Valid'),
                _ComplianceRow(label: 'Next Service', date: vehicle.nextService, status: 'Due soon', isAlert: true),
                const Divider(height: 48),
                const Text('REAL-TIME STATS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                _StatRow(label: 'Odometer', value: '${vehicle.odo} km', icon: LucideIcons.gauge),
                _StatRow(label: 'Current Fuel', value: '${vehicle.fuel}%', icon: LucideIcons.fuel),
                _StatRow(label: 'Last Fill', value: vehicle.lastFill, icon: LucideIcons.droplets),
                _StatRow(label: 'Driver', value: vehicle.driver, icon: LucideIcons.user),
                const Divider(height: 48),
                const Text('SERVICE HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 12),
                if (vehicle.serviceHistory.isEmpty)
                  const Text('No recent service records.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))
                else
                  ...vehicle.serviceHistory.map((s) => ListTile(title: Text(s.type), subtitle: Text(s.date), trailing: const Icon(LucideIcons.chevronRight, size: 14))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                  child: const Text('Schedule Maintenance')
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onDeactivate, 
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                  child: const Text('Deactivate Vehicle')
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

class _ComplianceRow extends StatelessWidget {
  final String label;
  final String date;
  final String status;
  final bool isAlert;
  const _ComplianceRow({required this.label, required this.date, required this.status, this.isAlert = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Expires: $date', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: (isAlert ? AppTheme.warning : AppTheme.success).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: isAlert ? AppTheme.warning : AppTheme.success, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatRow({required this.label, required this.value, required this.icon});
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
