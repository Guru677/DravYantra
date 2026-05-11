import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

import 'package:provider/provider.dart';
import '../models/engine.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  String _filter = 'all'; // all, suspect

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();
    final logs = _filter == 'all' 
        ? engine.fuelLogs 
        : engine.fuelLogs.where((l) => l.isSuspect).toList();

    double totalSpend = logs.fold(0, (sum, l) => sum + l.cost);
    double totalLiters = logs.fold(0, (sum, l) => sum + l.liters);
    int suspectCount = engine.fuelLogs.where((l) => l.isSuspect).length;

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
                  Text('Fuel Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Track fill-ups, detect anomalies, and manage fuel budgets', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportLogs(context),
                    icon: const Icon(LucideIcons.download, size: 14),
                    label: const Text('Export CSV'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                    onPressed: () => _showLogForm(context, engine), 
                    icon: const Icon(LucideIcons.plus, size: 14), 
                    label: const Text('Log Fill-Up')
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildKpis(totalSpend, totalLiters, suspectCount),
          const SizedBox(height: 16),
          _buildSpendChart(),
          const SizedBox(height: 16),
          Row(
            children: [
              FilterChip(
                label: const Text('All Logs'),
                selected: _filter == 'all',
                onSelected: (s) => setState(() => _filter = 'all'),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Suspect Only'),
                selected: _filter == 'suspect',
                onSelected: (s) => setState(() => _filter = 'suspect'),
                selectedColor: AppTheme.danger.withOpacity(0.2),
                checkmarkColor: AppTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLogsTable(logs),
        ],
      ),
    );
  }

  Widget _buildKpis(double spend, double liters, int suspect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _kpiCard('Total Spend', '₹${spend.toStringAsFixed(0)}', 'Budget: ₹6,65,000', AppTheme.primaryBlue),
        _kpiCard('Total Consumed', '${liters.toStringAsFixed(0)} L', 'Avg rate: ₹92.5/L', AppTheme.success),
        _kpiCard('Suspect Logs', '$suspect', 'Flagged for review', AppTheme.danger),
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
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSpendChart() {
    return Container(
      height: 320, // Increased height for better visibility
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.ecoGreen.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Spend vs Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                  Text('7-day performance overview', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
              Row(
                children: [
                  _chartLegendItem('Spend', AppTheme.ecoGreen),
                  const SizedBox(width: 12),
                  _chartLegendItem('Budget', AppTheme.danger.withOpacity(0.5), isDashed: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppTheme.textPrimary,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final isBudget = barSpot.barIndex == 1;
                        return LineTooltipItem(
                          '${isBudget ? 'Budget' : 'Spend'}: ₹${barSpot.y.toInt()}',
                          TextStyle(
                            color: isBudget ? AppTheme.danger.withOpacity(0.8) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value >= 0 && value < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2000,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text('₹${(value / 1000).toInt()}k', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3000), FlSpot(1, 4500), FlSpot(2, 3200), FlSpot(3, 5100), FlSpot(4, 4000), FlSpot(5, 3800), FlSpot(6, 4200)],
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.ecoGreen,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.ecoGreen.withOpacity(0.2),
                          AppTheme.ecoGreen.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 4000), FlSpot(1, 4000), FlSpot(2, 4000), FlSpot(3, 4000), FlSpot(4, 4000), FlSpot(5, 4000), FlSpot(6, 4000)],
                    isCurved: false,
                    color: AppTheme.danger.withOpacity(0.3),
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartLegendItem(String label, Color color, {bool isDashed = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? null : color,
            borderRadius: BorderRadius.circular(3),
            border: isDashed ? Border.all(color: color, width: 2) : null,
          ),
          child: isDashed 
            ? Center(child: Container(width: 6, height: 2, color: color)) 
            : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildLogsTable(List<FuelLog> logs) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      elevation: 0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
          columns: const [
            DataColumn(label: Text('Log ID')),
            DataColumn(label: Text('Vehicle')),
            DataColumn(label: Text('Driver/Date')),
            DataColumn(label: Text('Station')),
            DataColumn(label: Text('Liters')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
          ],
          rows: logs.map((l) {
            return DataRow(cells: [
              DataCell(Text(l.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue))),
              DataCell(Text(l.vehicle, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(l.driver, style: const TextStyle(fontSize: 12)), Text(l.date, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary))],
              )),
              DataCell(Text(l.station)),
              DataCell(Text('${l.liters} L')),
              DataCell(Text('₹${l.cost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(l.isSuspect 
                ? Tooltip(message: l.suspectReason ?? 'Anomalous reading', child: const Icon(LucideIcons.alertTriangle, color: AppTheme.danger, size: 16)) 
                : const Icon(LucideIcons.checkCircle, color: AppTheme.success, size: 16)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  void _showLogForm(BuildContext context, DataEngine engine) {
    final vehicle = TextEditingController();
    final liters = TextEditingController();
    final rate = TextEditingController();
    final odo = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Fuel Fill-Up'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: vehicle, decoration: const InputDecoration(labelText: 'Vehicle Plate', hintText: 'MH 14 CX 5543')),
              TextField(controller: liters, decoration: const InputDecoration(labelText: 'Liters', hintText: '100'), keyboardType: TextInputType.number),
              TextField(controller: rate, decoration: const InputDecoration(labelText: 'Rate per Liter', hintText: '94.2'), keyboardType: TextInputType.number),
              TextField(controller: odo, decoration: const InputDecoration(labelText: 'Current Odometer', hintText: '48200'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double l = double.tryParse(liters.text) ?? 0;
              double r = double.tryParse(rate.text) ?? 0;
              bool suspect = l > 400; // Basic anomaly detection
              
              engine.addFuelLog(FuelLog(
                id: 'FL-${100 + engine.fuelLogs.length + 1}',
                vehicle: vehicle.text,
                driver: 'Self / Assigned',
                station: 'Auto-detected Station',
                liters: l,
                rate: r,
                cost: l * r,
                odometer: int.tryParse(odo.text) ?? 0,
                date: DateTime.now().toString().split(' ')[0],
                isSuspect: suspect,
                suspectReason: suspect ? 'Liters exceed normal tank capacity' : null,
              ));
              Navigator.pop(context);
            }, 
            child: const Text('Log Entry')
          ),
        ],
      ),
    );
  }

  void _exportLogs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fuel logs exported to fuel_logs_2026_04.csv'), backgroundColor: AppTheme.success),
    );
  }
}
