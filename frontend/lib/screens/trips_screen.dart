import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/engine.dart';
import '../core/theme.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Trip? _selectedTrip;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();
    final trips = engine.trips;

    int running = trips.where((t) => t.status == 'running').length;
    int completed = trips.where((t) => t.status == 'completed').length;
    int pending = trips.where((t) => t.status == 'pending').length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _selectedTrip != null 
        ? _TripDetailDrawer(
            trip: _selectedTrip!,
            onClose: () => Navigator.pop(context),
            onStatusUpdate: (status) {
              engine.updateTripStatus(_selectedTrip!.id, status);
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
                    Text('Trip Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Schedule, track, and optimize fleet journeys', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ecoGreen, foregroundColor: Colors.white),
                  onPressed: () => _showTripForm(context, engine), 
                  icon: const Icon(LucideIcons.plus, size: 14), 
                  label: const Text('New Trip')
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildKpis(trips.length, running, completed, pending),
            const SizedBox(height: 16),
            _buildTripsGrid(context, trips),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis(int total, int running, int completed, int pending) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Total Trips', '$total', 'all time', AppTheme.ecoGreen),
        _kpiCard('Live Tracking', '$running', 'on road', Colors.blue),
        _kpiCard('Successful', '$completed', 'delivered', Colors.deepPurple),
        _kpiCard('Scheduled', '$pending', 'pending dispatch', AppTheme.warning),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String subtitle, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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

  Widget _buildTripsGrid(BuildContext context, List<Trip> trips) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 500,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final t = trips[index];
        final color = t.status == 'completed' ? AppTheme.ecoGreen : t.status == 'running' ? Colors.blue : AppTheme.warning;

        return InkWell(
          onTap: () {
            setState(() => _selectedTrip = t);
            _scaffoldKey.currentState?.openEndDrawer();
          },
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withOpacity(0.1))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(t.id, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                          ),
                          if (t.delayMinutes > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(4)),
                              child: Text('DELAY ${t.delayMinutes}M', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      _Badge(label: t.status.toUpperCase(), color: color),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(LucideIcons.mapPin, size: 14, color: AppTheme.ecoGreen),
                      const SizedBox(width: 8),
                      Text(t.from, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(LucideIcons.arrowRight, size: 12, color: AppTheme.textSecondary)),
                      Text(t.to, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.user, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(t.driver, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.truck, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(t.vehicle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const Spacer(),
                  if (t.status == 'running') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trip Progress', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        Text('${(t.progress * 100).toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: t.progress, backgroundColor: Colors.blue.withOpacity(0.1), color: Colors.blue, minHeight: 6),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.box, size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(t.load, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTripForm(BuildContext context, DataEngine engine) {
    final vehicle = TextEditingController();
    final driver = TextEditingController();
    final from = TextEditingController();
    final to = TextEditingController();
    final eway = TextEditingController();
    final waypoints = TextEditingController();
    final tolls = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Trip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle Plate')),
              TextField(controller: driver, decoration: const InputDecoration(labelText: 'Assigned Driver')),
              TextField(controller: from, decoration: const InputDecoration(labelText: 'Source City')),
              TextField(controller: to, decoration: const InputDecoration(labelText: 'Destination City')),
              TextField(controller: eway, decoration: const InputDecoration(labelText: 'e-Way Bill Number')),
              TextField(controller: waypoints, decoration: const InputDecoration(labelText: 'Waypoints (comma separated)')),
              TextField(controller: tolls, decoration: const InputDecoration(labelText: 'Toll Count')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              engine.addTrip(Trip(
                id: 'TRP-${4403 + engine.trips.length}',
                vehicle: vehicle.text,
                driver: driver.text,
                from: from.text,
                to: to.text,
                load: 'General Cargo',
                client: 'New Client',
                status: 'pending',
                ewayBill: eway.text,
                date: DateTime.now().toString().split(' ')[0],
                progress: 0.0,
                waypoints: waypoints.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                tollCount: int.tryParse(tolls.text) ?? 0,
              ));
              Navigator.pop(context);
            }, 
            child: const Text('Dispatch')
          ),
        ],
      ),
    );
  }
}

class _TripDetailDrawer extends StatelessWidget {
  final Trip trip;
  final VoidCallback onClose;
  final Function(String) onStatusUpdate;

  const _TripDetailDrawer({required this.trip, required this.onClose, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final color = trip.status == 'completed' ? AppTheme.ecoGreen : trip.status == 'running' ? Colors.blue : AppTheme.warning;

    return Drawer(
      width: 450,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            color: color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(trip.id, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: Colors.white)),
                  ],
                ),
                Text('${trip.from} → ${trip.to}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
                const SizedBox(height: 16),
                _Badge(label: trip.status.toUpperCase(), color: Colors.white, textColor: color),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('TRIP INFORMATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                _InfoRow(label: 'Client', value: trip.client, icon: LucideIcons.briefcase),
                _InfoRow(label: 'Load Description', value: trip.load, icon: LucideIcons.box),
                _InfoRow(label: 'e-Way Bill', value: trip.ewayBill, icon: LucideIcons.fileText),
                _InfoRow(label: 'Date', value: trip.date, icon: LucideIcons.calendar),
                _InfoRow(label: 'Waypoints', value: trip.waypoints.isEmpty ? 'None' : trip.waypoints.join(', '), icon: LucideIcons.mapPin),
                _InfoRow(label: 'Tolls Passed', value: '${trip.tollCount}', icon: LucideIcons.creditCard),
                const Divider(height: 48),
                const Text('ASSETS ASSIGNED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                _InfoRow(label: 'Vehicle', value: trip.vehicle, icon: LucideIcons.truck),
                _InfoRow(label: 'Driver', value: trip.driver, icon: LucideIcons.user),
                const Divider(height: 48),
                if (trip.status == 'pending')
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('running'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Start Trip'),
                  ),
                if (trip.status == 'running')
                  ElevatedButton(
                    onPressed: () => onStatusUpdate('completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ecoGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Mark as Completed'),
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
  final Color? textColor;
  const _Badge({required this.label, required this.color, this.textColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(label, style: TextStyle(color: textColor ?? color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
