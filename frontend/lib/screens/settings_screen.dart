import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

import 'package:provider/provider.dart';
import '../models/engine.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final engine = context.watch<DataEngine>();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryBlue,
            tabs: [
              Tab(text: 'Organization'),
              Tab(text: 'Account'),
              Tab(text: 'Alert Thresholds'),
              Tab(text: 'Integrations'),
              Tab(text: 'Security'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrgTab(engine),
            _buildAccountTab(engine),
            _buildAlertsTab(engine),
            _buildIntegrationsTab(engine),
            _buildSecurityTab(engine),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgTab(DataEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Organization Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Manage company legal identity and contact info', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          _buildTextField('Company Name', engine.org.name),
          _buildTextField('GSTIN', engine.org.gstin),
          _buildTextField('PAN', engine.org.pan),
          Row(
            children: [
              Expanded(child: _buildTextField('City', engine.org.city)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('State', engine.org.state)),
            ],
          ),
          _buildTextField('Contact Email / Phone', engine.org.contact),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(150, 45)),
            child: const Text('Save Organization Info'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(DataEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Personal settings and role-based permissions', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          _buildTextField('Full Name', engine.user.name),
          _buildTextField('Work Email', engine.user.email),
          _buildTextField('Phone Number', engine.user.phone),
          _buildTextField('Role', engine.user.role, enabled: false),
          _buildTextField('Timezone', engine.user.timezone),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, minimumSize: const Size(150, 45)),
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(DataEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Alert Thresholds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Define limits that trigger system notifications', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          _buildThresholdSlider('Over-speed Limit', '${engine.alertSettings.speedThreshold} km/h', engine.alertSettings.speedThreshold / 120),
          _buildThresholdSlider('Idle Duration Limit', '${engine.alertSettings.idleLimit} mins', engine.alertSettings.idleLimit / 60),
          _buildThresholdSlider('Fuel Drop Sensitivity', '${engine.alertSettings.fuelDropThreshold}%', engine.alertSettings.fuelDropThreshold / 20),
          _buildThresholdSlider('FASTag Low Balance', '₹${engine.alertSettings.fastagThreshold}', engine.alertSettings.fastagThreshold / 2000),
          _buildThresholdSlider('Low Mileage Threshold', '${engine.alertSettings.mileageThreshold} km/L', (engine.alertSettings.mileageThreshold ?? 3.0) / 10.0),
          const Divider(height: 48),
          const Text('Notification Channels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildChannelToggle('WhatsApp Alerts', 'Critical safety and fuel events', engine.alertSettings.whatsappEnabled),
          _buildChannelToggle('SMS Alerts', 'Compliance and network events', engine.alertSettings.smsEnabled),
          _buildChannelToggle('Email Alerts', 'Reports and non-critical updates', true),
          _buildChannelToggle('Push Notifications', 'Real-time dashboard updates', engine.alertSettings.pushEnabled),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(DataEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const TextField(decoration: InputDecoration(labelText: 'Current Password', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'New Password', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder())),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
            child: const Text('Change Password'),
          ),
          const Divider(height: 48),
          const Text('Two-Factor Authentication', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable 2FA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Secure your account with a secondary code', style: TextStyle(fontSize: 12)),
            trailing: Switch(value: false, onChanged: (v) {}, activeColor: AppTheme.primaryBlue),
          ),
          const Divider(height: 48),
          const Text('Developer API Keys', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Use API keys to access fleet data programmatically.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('sk_live_...5f4d', style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold))),
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.copy, size: 16)),
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.danger)),
            ],
          ),
          const Divider(height: 48),
          const Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.danger)),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
                child: const Text('Export Account Data'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsTab(DataEngine engine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('External Integrations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Connect third-party services to enrich fleet data', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          _buildIntegrationTile('Vahan API', 'Vehicle registration and compliance data', true),
          _buildIntegrationTile('FASTag', 'Electronic toll collection and balance tracking', true),
          _buildIntegrationTile('GST Portal', 'e-Way bill generation and verification', false),
          _buildIntegrationTile('Insurance Providers', 'Auto-fetch insurance renewal dates', false),
          _buildIntegrationTile('GPS Providers', 'Connect external GPS hardware', true),
        ],
      ),
    );
  }

  Widget _buildIntegrationTile(String title, String desc, bool connected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: (connected ? AppTheme.success : AppTheme.textSecondary).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(connected ? 'CONNECTED' : 'DISCONNECTED', style: TextStyle(color: connected ? AppTheme.success : AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildThresholdSlider(String title, String value, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(value, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: AppTheme.primaryBlue, minHeight: 6),
        ],
      ),
    );
  }

  Widget _buildChannelToggle(String title, String desc, bool value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: Switch(value: value, onChanged: (v) {}, activeColor: AppTheme.primaryBlue),
    );
  }
}
