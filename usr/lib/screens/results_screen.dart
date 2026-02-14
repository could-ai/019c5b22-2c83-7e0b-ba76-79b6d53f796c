import 'package:flutter/material.dart';
import '../models/placement_data.dart';
import '../services/intel_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late AnalysisEntry _entry;
  Map<String, String> _skillConfidenceMap = {};
  double _finalScore = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entry = ModalRoute.of(context)!.settings.arguments as AnalysisEntry;
    _skillConfidenceMap = Map.from(_entry.skillConfidenceMap);
    _finalScore = _entry.finalScore;
  }

  void _toggleConfidence(String skill) {
    setState(() {
      _skillConfidenceMap[skill] = _skillConfidenceMap[skill] == 'know' ? 'practice' : 'know';
      _finalScore = AnalysisService.computeFinalScore(_entry.baseScore, _skillConfidenceMap);
    });
    // Persist the update
    AnalysisService.updateEntry(_entry.id, _skillConfidenceMap, _finalScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildSkillsSection(),
            const SizedBox(height: 24),
            _buildRoundMappingSection(),
            const SizedBox(height: 24),
            _buildChecklistSection(),
            const SizedBox(height: 24),
            _buildPlanSection(),
            const SizedBox(height: 24),
            _buildQuestionsSection(),
            const SizedBox(height: 24),
            _buildDemoNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _entry.company.isNotEmpty ? _entry.company : 'Job Analysis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (_entry.role.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _entry.role,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildScoreChip('Base Score', _entry.baseScore),
                const SizedBox(width: 16),
                _buildScoreChip('Final Score', _finalScore),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(String label, double score) {
    return Chip(
      label: Text('$label: ${score.toStringAsFixed(1)}'),
      backgroundColor: Colors.deepPurple.shade100,
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Extracted Skills",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 16),
        if (_entry.extractedSkills.allSkills.isEmpty)
          const Text('No specific skills extracted. Focus on communication and basic coding.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _entry.extractedSkills.allSkills.map((skill) {
              final confidence = _skillConfidenceMap[skill] ?? 'know';
              return FilterChip(
                label: Text(skill),
                selected: confidence == 'practice',
                onSelected: (_) => _toggleConfidence(skill),
                selectedColor: Colors.orange.shade100,
                checkmarkColor: Colors.orange,
              );
            }).toList(),
          ),
        const SizedBox(height: 8),
        const Text(
          'Tap skills to toggle confidence level (affects final score).',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRoundMappingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Round Mapping Strategy",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entry.roundMapping.length,
          itemBuilder: (context, index) {
            final round = _entry.roundMapping[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      round.roundTitle,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: round.focusAreas.map((area) => Chip(label: Text(area))).toList(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Why it matters: ${round.whyItMatters}',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Preparation Checklist",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entry.checklist.length,
          itemBuilder: (context, index) {
            final checklist = _entry.checklist[index];
            return ExpansionTile(
              title: Text(checklist.roundTitle),
              children: checklist.items.map((item) => ListTile(title: Text('• $item'))).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "7-Day Preparation Plan",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _entry.plan7Days.length,
          itemBuilder: (context, index) {
            final day = _entry.plan7Days[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.day}: ${day.focus}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ...day.tasks.map((task) => Text('• $task')),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sample Interview Questions",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
        ),
        const SizedBox(height: 16),
        ..._entry.questions.map((question) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $question'),
            )),
      ],
    );
  }

  Widget _buildDemoNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Demo Mode: Analysis generated heuristically based on JD input.",
              style: TextStyle(color: Colors.amber[900], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}