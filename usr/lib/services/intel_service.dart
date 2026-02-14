import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/placement_data.dart';

class AnalysisService {
  static const String _historyKey = 'analysis_history';
  static const Uuid _uuid = Uuid();

  static Future<List<AnalysisEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    List<AnalysisEntry> history = [];
    bool hasCorrupted = false;
    for (final jsonStr in historyJson) {
      try {
        final json = jsonDecode(jsonStr);
        history.add(AnalysisEntry.fromJson(json));
      } catch (e) {
        hasCorrupted = true;
      }
    }
    if (hasCorrupted) {
      // Show message that one entry couldn't be loaded
      // This will be handled in the UI
    }
    return history;
  }

  static Future<void> saveEntry(AnalysisEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    historyJson.insert(0, jsonEncode(entry.toJson()));
    await prefs.setStringList(_historyKey, historyJson);
  }

  static Future<void> updateEntry(String id, Map<String, String> skillConfidenceMap, double finalScore) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    for (int i = 0; i < historyJson.length; i++) {
      try {
        final json = jsonDecode(historyJson[i]);
        if (json['id'] == id) {
          json['skillConfidenceMap'] = skillConfidenceMap;
          json['finalScore'] = finalScore;
          json['updatedAt'] = DateTime.now().toIso8601String();
          historyJson[i] = jsonEncode(json);
          break;
        }
      } catch (e) {
        // Skip corrupted
      }
    }
    await prefs.setStringList(_historyKey, historyJson);
  }

  static AnalysisEntry analyzeJobDescription(String jdText, String company, String role) {
    final id = _uuid.v4();
    final createdAt = DateTime.now();
    final updatedAt = createdAt.toIso8601String();

    final extractedSkills = _extractSkills(jdText);
    final roundMapping = _generateRoundMapping(extractedSkills, company);
    final checklist = _generateChecklist(roundMapping);
    final plan7Days = _generate7DayPlan(extractedSkills);
    final questions = _generateQuestions(extractedSkills);
    final baseScore = _computeBaseScore(extractedSkills);
    final skillConfidenceMap = _initializeSkillConfidenceMap(extractedSkills);
    final finalScore = baseScore; // Initial finalScore equals baseScore

    return AnalysisEntry(
      id: id,
      createdAt: createdAt,
      company: company,
      role: role,
      jdText: jdText,
      extractedSkills: extractedSkills,
      roundMapping: roundMapping,
      checklist: checklist,
      plan7Days: plan7Days,
      questions: questions,
      baseScore: baseScore,
      skillConfidenceMap: skillConfidenceMap,
      finalScore: finalScore,
      updatedAt: updatedAt,
    );
  }

  static ExtractedSkills _extractSkills(String jdText) {
    final text = jdText.toLowerCase();
    List<String> coreCS = [];
    List<String> languages = [];
    List<String> web = [];
    List<String> data = [];
    List<String> cloud = [];
    List<String> testing = [];
    List<String> other = [];

    // Simple keyword-based extraction
    if (text.contains('dsa') || text.contains('algorithm') || text.contains('data structure')) coreCS.add('DSA');
    if (text.contains('os') || text.contains('operating system')) coreCS.add('OS');
    if (text.contains('dbms') || text.contains('database')) coreCS.add('DBMS');
    if (text.contains('network') || text.contains('cn')) coreCS.add('Computer Networks');

    if (text.contains('java')) languages.add('Java');
    if (text.contains('python')) languages.add('Python');
    if (text.contains('javascript') || text.contains('js')) languages.add('JavaScript');
    if (text.contains('c++')) languages.add('C++');
    if (text.contains('go')) languages.add('Go');

    if (text.contains('react')) web.add('React');
    if (text.contains('node') || text.contains('nodejs')) web.add('Node.js');
    if (text.contains('html') || text.contains('css')) web.add('HTML/CSS');
    if (text.contains('angular')) web.add('Angular');

    if (text.contains('sql') || text.contains('mysql')) data.add('SQL');
    if (text.contains('mongodb')) data.add('MongoDB');
    if (text.contains('big data') || text.contains('hadoop')) data.add('Big Data');
    if (text.contains('machine learning') || text.contains('ml')) data.add('Machine Learning');

    if (text.contains('aws')) cloud.add('AWS');
    if (text.contains('azure')) cloud.add('Azure');
    if (text.contains('gcp') || text.contains('google cloud')) cloud.add('GCP');
    if (text.contains('docker')) cloud.add('Docker');
    if (text.contains('kubernetes')) cloud.add('Kubernetes');

    if (text.contains('testing') || text.contains('test')) testing.add('Unit Testing');
    if (text.contains('selenium')) testing.add('Selenium');

    // If no skills detected, populate other
    if (coreCS.isEmpty && languages.isEmpty && web.isEmpty && data.isEmpty && cloud.isEmpty && testing.isEmpty) {
      other = ['Communication', 'Problem solving', 'Basic coding', 'Projects'];
    }

    return ExtractedSkills(
      coreCS: coreCS,
      languages: languages,
      web: web,
      data: data,
      cloud: cloud,
      testing: testing,
      other: other,
    );
  }

  static List<RoundMapping> _generateRoundMapping(ExtractedSkills skills, String company) {
    final normalizedCompany = company.toLowerCase().trim();
    final knownEnterprises = {'amazon', 'google', 'microsoft', 'infosys', 'tcs', 'wipro', 'accenture', 'ibm', 'oracle', 'cisco', 'meta', 'netflix', 'adobe', 'salesforce', 'capgemini', 'deloitte', 'cognizant', 'hcl', 'tech mahindra'};
    final isEnterprise = knownEnterprises.any((e) => normalizedCompany.contains(e));

    List<RoundMapping> rounds = [];
    final allSkills = skills.allSkills;
    final hasDSA = allSkills.any((s) => s.toLowerCase().contains('dsa'));
    final hasWeb = skills.web.isNotEmpty;
    final hasSystemDesign = allSkills.any((s) => s.toLowerCase().contains('system') || s.toLowerCase().contains('design'));

    if (isEnterprise) {
      rounds.add(RoundMapping(
        roundTitle: 'Round 1: Online Assessment',
        focusAreas: ['Aptitude', 'DSA'],
        whyItMatters: 'Filters candidates based on raw problem-solving speed and accuracy.',
      ));
      rounds.add(RoundMapping(
        roundTitle: 'Round 2: Technical Interview I',
        focusAreas: ['DSA', 'Core CS'],
        whyItMatters: 'Validates fundamental computer science knowledge and coding proficiency.',
      ));
      if (hasSystemDesign) {
        rounds.add(RoundMapping(
          roundTitle: 'Round 3: System Design & Projects',
          focusAreas: ['HLD/LLD', 'Projects'],
          whyItMatters: 'Assesses ability to build scalable systems and architectural thinking.',
        ));
      } else {
        rounds.add(RoundMapping(
          roundTitle: 'Round 3: Advanced Technical',
          focusAreas: ['Complex Problem Solving', 'Projects'],
          whyItMatters: 'Tests depth of understanding in projects and advanced algorithms.',
        ));
      }
      rounds.add(RoundMapping(
        roundTitle: 'Round 4: Managerial / HR',
        focusAreas: ['Behavioral', 'Culture Fit'],
        whyItMatters: 'Ensures alignment with company values and team dynamics.',
      ));
    } else {
      if (hasWeb) {
        rounds.add(RoundMapping(
          roundTitle: 'Round 1: Practical Coding / Take-home',
          focusAreas: ['Build Feature', 'Fix Bug'],
          whyItMatters: 'Proves you can ship code and work with the actual tech stack.',
        ));
      } else {
        rounds.add(RoundMapping(
          roundTitle: 'Round 1: Problem Solving & Logic',
          focusAreas: ['Practical Coding', 'Logic'],
          whyItMatters: 'Tests ability to write clean, working code for real-world problems.',
        ));
      }
      rounds.add(RoundMapping(
        roundTitle: 'Round 2: Technical Discussion',
        focusAreas: ['System Architecture', 'Stack Deep Dive'],
        whyItMatters: 'Evaluates understanding of how systems work together and trade-offs.',
        ));
      rounds.add(RoundMapping(
        roundTitle: 'Round 3: Culture Fit / Founder Round',
        focusAreas: ['Vision Alignment', 'Soft Skills'],
        whyItMatters: 'Critical for small teams; ensures you share the startup\'s passion and drive.',
      ));
    }
    return rounds;
  }

  static List<ChecklistItem> _generateChecklist(List<RoundMapping> rounds) {
    return rounds.map((round) {
      List<String> items = [];
      switch (round.roundTitle) {
        case 'Round 1: Online Assessment':
          items = ['Practice LeetCode medium/hard problems', 'Review time complexity analysis', 'Mock aptitude tests'];
          break;
        case 'Round 2: Technical Interview I':
          items = ['Revise OS, DBMS, CN concepts', 'Code common algorithms', 'Prepare project explanations'];
          break;
        case 'Round 3: System Design & Projects':
          items = ['Study system design patterns', 'Draw architecture diagrams', 'Deep dive into resume projects'];
          break;
        case 'Round 3: Advanced Technical':
          items = ['Solve advanced coding problems', 'Review complex algorithms', 'Strengthen project portfolio'];
          break;
        case 'Round 4: Managerial / HR':
          items = ['Prepare STAR method answers', 'Research company culture', 'Practice behavioral questions'];
          break;
        case 'Round 1: Practical Coding / Take-home':
          items = ['Build sample projects', 'Practice debugging', 'Learn version control'];
          break;
        case 'Round 1: Problem Solving & Logic':
          items = ['Code daily challenges', 'Focus on clean code', 'Practice pair programming'];
          break;
        case 'Round 2: Technical Discussion':
          items = ['Learn architectural patterns', 'Understand trade-offs', 'Prepare tech stack questions'];
          break;
        case 'Round 3: Culture Fit / Founder Round':
          items = ['Research company mission', 'Prepare passion stories', 'Practice communication skills'];
          break;
      }
      return ChecklistItem(roundTitle: round.roundTitle, items: items);
    }).toList();
  }

  static List<DayPlan> _generate7DayPlan(ExtractedSkills skills) {
    final allSkills = skills.allSkills;
    List<DayPlan> plan = [];
    if (allSkills.isEmpty) {
      // Default plan for basic skills
      plan = [
        DayPlan(day: 'Day 1', focus: 'Communication', tasks: ['Practice speaking about projects', 'Write cover letter']),
        DayPlan(day: 'Day 2', focus: 'Problem Solving', tasks: ['Solve basic logic puzzles', 'Think step-by-step']),
        DayPlan(day: 'Day 3', focus: 'Basic Coding', tasks: ['Learn basic syntax', 'Write simple programs']),
        DayPlan(day: 'Day 4', focus: 'Projects', tasks: ['Build a simple app', 'Document your work']),
        DayPlan(day: 'Day 5', focus: 'Review', tasks: ['Review all basics', 'Mock interview']),
        DayPlan(day: 'Day 6', focus: 'Practice', tasks: ['More coding practice', 'Feedback session']),
        DayPlan(day: 'Day 7', focus: 'Rest & Reflect', tasks: ['Relax', 'Plan next week']),
      ];
    } else {
      // Skill-based plan
      plan = [
        DayPlan(day: 'Day 1', focus: 'Core Skills Review', tasks: ['Revise ${skills.coreCS.join(', ')}', 'Solve related problems']),
        DayPlan(day: 'Day 2', focus: 'Languages Practice', tasks: ['Code in ${skills.languages.join(', ')}', 'Build small utilities']),
        DayPlan(day: 'Day 3', focus: 'Web/Data/Cloud', tasks: ['Work with ${[...skills.web, ...skills.data, ...skills.cloud].join(', ')}', 'Create mini-projects']),
        DayPlan(day: 'Day 4', focus: 'Testing & Other', tasks: ['Practice ${skills.testing.join(', ')}', 'Improve ${skills.other.join(', ')}']),
        DayPlan(day: 'Day 5', focus: 'System Design', tasks: ['Design simple systems', 'Learn patterns']),
        DayPlan(day: 'Day 6', focus: 'Mock Interviews', tasks: ['Simulate rounds', 'Get feedback']),
        DayPlan(day: 'Day 7', focus: 'Final Prep', tasks: ['Review weak areas', 'Relax before interview']),
      ];
    }
    return plan;
  }

  static List<String> _generateQuestions(ExtractedSkills skills) {
    List<String> questions = [];
    final allSkills = skills.allSkills;
    if (allSkills.isEmpty) {
      questions = [
        'Tell me about a project you worked on.',
        'How do you approach problem solving?',
        'What is your coding experience?',
        'How do you handle communication in a team?',
      ];
    } else {
      questions.add('Explain your experience with ${allSkills.take(3).join(', ')}.');
      questions.add('How would you design a system for ${skills.web.isNotEmpty ? skills.web.first : 'a web app'}?');
      questions.add('Walk me through a complex problem you solved.');
      questions.add('What are your strengths in ${skills.languages.isNotEmpty ? skills.languages.first : 'coding'}?');
    }
    return questions;
  }

  static double _computeBaseScore(ExtractedSkills skills) {
    int score = 0;
    score += skills.coreCS.length * 10;
    score += skills.languages.length * 8;
    score += skills.web.length * 7;
    score += skills.data.length * 6;
    score += skills.cloud.length * 5;
    score += skills.testing.length * 4;
    score += skills.other.length * 3;
    return score.toDouble();
  }

  static Map<String, String> _initializeSkillConfidenceMap(ExtractedSkills skills) {
    Map<String, String> map = {};
    for (final skill in skills.allSkills) {
      map[skill] = 'know'; // Default to know
    }
    return map;
  }

  static double computeFinalScore(double baseScore, Map<String, String> confidenceMap) {
    double adjustment = 0;
    for (final confidence in confidenceMap.values) {
      if (confidence == 'practice') {
        adjustment -= 5; // Deduct for skills needing practice
      }
    }
    return (baseScore + adjustment).clamp(0, 100);
  }
}

// Legacy service for compatibility
class IntelService {
  static final Set<String> _knownEnterprises = {
    'amazon', 'google', 'microsoft', 'infosys', 'tcs', 'wipro', 'accenture',
    'ibm', 'oracle', 'cisco', 'meta', 'netflix', 'adobe', 'salesforce',
    'capgemini', 'deloitte', 'cognizant', 'hcl', 'tech mahindra'
  };

  static final Set<String> _fintechKeywords = {'bank', 'pay', 'finance', 'wealth', 'capital', 'credit'};
  static final Set<String> _healthKeywords = {'health', 'med', 'pharma', 'care', 'life'};
  static final Set<String> _edtechKeywords = {'edu', 'learn', 'academy', 'school', 'class'};
  static final Set<String> _ecommKeywords = {'shop', 'mart', 'store', 'retail', 'commerce'};

  static CompanyIntel generateIntel(String companyName, List<String> skills) {
    final normalizedName = companyName.toLowerCase().trim();
    
    // Heuristic: Check if known enterprise
    bool isEnterprise = _knownEnterprises.any((e) => normalizedName.contains(e));

    // Heuristic: Size & Type
    String size = isEnterprise ? "Enterprise (2000+)" : "Startup (<200)";
    String type = isEnterprise ? "MNC / Corporate" : "Product Startup";
    
    // Heuristic: Industry
    String industry = _inferIndustry(normalizedName);

    // Heuristic: Hiring Focus
    String hiringFocus = isEnterprise
        ? "Structured DSA + Core Fundamentals"
        : "Practical Problem Solving + Stack Depth";

    // Heuristic: Rounds
    List<Round> rounds = _generateRounds(isEnterprise, skills);

    return CompanyIntel(
      name: companyName,
      industry: industry,
      size: size,
      type: type,
      hiringFocus: hiringFocus,
      rounds: rounds,
      timestamp: DateTime.now(),
    );
  }

  static String _inferIndustry(String name) {
    if (_fintechKeywords.any((k) => name.contains(k))) return "FinTech";
    if (_healthKeywords.any((k) => name.contains(k))) return "HealthTech";
    if (_edtechKeywords.any((k) => name.contains(k))) return "EdTech";
    if (_ecommKeywords.any((k) => name.contains(k))) return "E-Commerce";
    return "Technology Services";
  }

  static List<Round> _generateRounds(bool isEnterprise, List<String> skills) {
    List<Round> rounds = [];
    bool hasDSA = skills.any((s) => s.toLowerCase().contains('dsa') || s.toLowerCase().contains('algorithm'));
    bool hasWeb = skills.any((s) => s.toLowerCase().contains('react') || s.toLowerCase().contains('node') || s.toLowerCase().contains('web'));
    bool hasSystemDesign = skills.any((s) => s.toLowerCase().contains('system') || s.toLowerCase().contains('design'));

    if (isEnterprise) {
      // Enterprise Flow
      rounds.add(Round(
        title: "Round 1: Online Assessment",
        description: "Aptitude + DSA (Medium/Hard)",
        whyItMatters: "Filters candidates based on raw problem-solving speed and accuracy.",
        icon: Icons.computer,
      ));

      rounds.add(Round(
        title: "Round 2: Technical Interview I",
        description: "DSA + Core CS (OS, DBMS, CN)",
        whyItMatters: "Validates fundamental computer science knowledge and coding proficiency.",
        icon: Icons.code,
      ));

      if (hasSystemDesign) {
        rounds.add(Round(
          title: "Round 3: System Design & Projects",
          description: "HLD/LLD + Deep dive into projects",
          whyItMatters: "Assesses ability to build scalable systems and architectural thinking.",
          icon: Icons.architecture,
        ));
      } else {
        rounds.add(Round(
          title: "Round 3: Advanced Technical",
          description: "Complex Problem Solving + Projects",
          whyItMatters: "Tests depth of understanding in projects and advanced algorithms.",
          icon: Icons.developer_board,
        ));
      }

      rounds.add(Round(
        title: "Round 4: Managerial / HR",
        description: "Behavioral + Culture Fit",
        whyItMatters: "Ensures alignment with company values and team dynamics.",
        icon: Icons.people,
      ));

    } else {
      // Startup Flow
      if (hasWeb) {
        rounds.add(Round(
          title: "Round 1: Practical Coding / Take-home",
          description: "Build a feature or fix a bug (React/Node)",
          whyItMatters: "Proves you can ship code and work with the actual tech stack.",
          icon: Icons.build,
        ));
      } else {
        rounds.add(Round(
          title: "Round 1: Problem Solving & Logic",
          description: "Practical coding challenges",
          whyItMatters: "Tests ability to write clean, working code for real-world problems.",
          icon: Icons.code,
        ));
      }

      rounds.add(Round(
        title: "Round 2: Technical Discussion",
        description: "System Architecture + Stack Deep Dive",
        whyItMatters: "Evaluates understanding of how systems work together and trade-offs.",
        icon: Icons.settings_input_component,
      ));

      rounds.add(Round(
        title: "Round 3: Culture Fit / Founder Round",
        description: "Vision alignment + Soft skills",
        whyItMatters: "Critical for small teams; ensures you share the startup's passion and drive.",
        icon: Icons.emoji_people,
      ));
    }

    return rounds;
  }
}