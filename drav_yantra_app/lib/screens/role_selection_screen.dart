import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.2),
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryBlue : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.primaryBlue : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This role is coming soon!'),
        backgroundColor: AppTheme.textPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Container
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, Color(0xFF1e3a8a)], // Brand and Brand-Dark
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.truck,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  
                  const Text(
                    'DravYantra',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select your account type to proceed\nwith the fleet intelligence platform.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),

                  _buildRoleCard(
                    context,
                    title: 'Fleet Owner',
                    subtitle: 'Manage vehicles, drivers, and operations',
                    icon: LucideIcons.building,
                    onTap: () => context.push('/login'),
                    isActive: true,
                  ),
                  
                  _buildRoleCard(
                    context,
                    title: 'Driver',
                    subtitle: 'View trips, routes, and log fuel',
                    icon: LucideIcons.user,
                    onTap: () => _showComingSoon(context),
                  ),
                  
                  _buildRoleCard(
                    context,
                    title: 'System Admin',
                    subtitle: 'Configure platform settings and tenants',
                    icon: LucideIcons.settings,
                    onTap: () => _showComingSoon(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
