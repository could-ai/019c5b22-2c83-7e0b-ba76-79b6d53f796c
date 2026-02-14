import 'package:flutter/material.dart';
import '../models/placement_data.dart';
import '../services/intel_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  
  // Simple in-memory history
  static final List<CompanyIntel> _history = [];

  void _analyze() {
    if (_formKey.currentState!.validate()) {
      final companyName = _companyController.text;
      final skills = _skillsController.text.split(',').map((e) => e.trim()).toList();

      // Generate intel to save to history immediately (simulating persistence)
      final intel = IntelService.generateIntel(companyName, skills);
      setState(() {
        _history.insert(0, intel);
      });

      Navigator.pushNamed(
        context,
        '/results',
        arguments: {
          'companyName': companyName,
          'skills': skills,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Readiness'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Analyze Your Target Company",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the company name and your skills to get tailored interview rounds and insights.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: "Target Company Name",
                      hintText: "e.g. Amazon, Infosys, Cred",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a company name' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _skillsController,
                    decoration: InputDecoration(
                      labelText: "Your Key Skills (comma separated)",
                      hintText: "e.g. Java, DSA, React, System Design",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.code),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter at least one skill' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _analyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Generate Intel & Rounds", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (_history.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                "Recent Analysis History",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(item.name[0].toUpperCase()),
                      ),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${item.size} • ${item.rounds.length} Rounds"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Re-navigate to results with saved data
                         Navigator.pushNamed(
                          context,
                          '/results',
                          arguments: {
                            'companyName': item.name,
                            'skills': ['(From History)'], // Simplified for history tap
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
