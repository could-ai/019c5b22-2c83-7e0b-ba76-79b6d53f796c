import 'package:flutter/material.dart';
import '../services/intel_service.dart';
import '../models/placement_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _jdController = TextEditingController();
  
  List<AnalysisEntry> _history = [];
  bool _isLoadingHistory = true;
  String? _corruptedMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final history = await AnalysisService.loadHistory();
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
        _corruptedMessage = 'Failed to load history.';
      });
    }
  }

  void _analyze() {
    if (_formKey.currentState!.validate()) {
      final company = _companyController.text.trim();
      final role = _roleController.text.trim();
      final jdText = _jdController.text.trim();

      // Check JD length and show warning
      if (jdText.length < 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This JD is too short to analyze deeply. Paste full JD for better output.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      final entry = AnalysisService.analyzeJobDescription(jdText, company, role);
      
      // Save to history
      AnalysisService.saveEntry(entry);
      
      // Update local history
      setState(() {
        _history.insert(0, entry);
      });

      Navigator.pushNamed(
        context,
        '/results',
        arguments: entry,
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
              "Analyze Your Target Job",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Paste the job description to get tailored interview prep, rounds, and insights.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _jdController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: "Job Description (JD)",
                      hintText: "Paste the full job description here...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the job description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      labelText: "Company Name (Optional)",
                      hintText: "e.g. Amazon, Infosys, Cred",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _roleController,
                    decoration: InputDecoration(
                      labelText: "Role/Position (Optional)",
                      hintText: "e.g. Software Engineer, Frontend Developer",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.work),
                    ),
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
                      child: const Text("Generate Analysis", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            if (_isLoadingHistory)
              const Center(child: CircularProgressIndicator())
            else if (_corruptedMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _corruptedMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_history.isNotEmpty) ...[
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
                        child: Text((item.company.isNotEmpty ? item.company[0] : 'J').toUpperCase()),
                      ),
                      title: Text(item.company.isNotEmpty ? item.company : 'Job Analysis'),
                      subtitle: Text('${item.extractedSkills.allSkills.length} skills • Score: ${item.finalScore.toStringAsFixed(1)}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/results',
                          arguments: item,
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