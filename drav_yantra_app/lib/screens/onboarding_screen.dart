import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _companyName = TextEditingController();
  final _gstin = TextEditingController();
  final _contact = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitOnboarding() async {
    if (_companyName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company name is required')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        final response = await http.post(
          Uri.parse('http://172.22.231.146:3000/api/onboarding'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'company_name': _companyName.text.trim(),
            'gstin': _gstin.text.trim(),
            'contact_number': _contact.text.trim(),
            'city': _city.text.trim(),
            'state': _state.text.trim(),
          }),
        );
        
        if (response.statusCode == 200 && mounted) {
          context.go('/dashboard');
        } else {
          throw Exception('Failed to save onboarding data');
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Fleet Setup', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryBlue,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 500,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('One-Time Setup', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                const Text('Please provide your organization details to personalize your dashboard.', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                
                TextField(
                  controller: _companyName,
                  decoration: const InputDecoration(labelText: 'Company/Organization Name *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _gstin,
                  decoration: const InputDecoration(labelText: 'GSTIN', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contact,
                  decoration: const InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _city,
                        decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _state,
                        decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isLoading ? null : _submitOnboarding,
                    child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
