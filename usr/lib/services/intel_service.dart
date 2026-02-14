import 'package:flutter/material.dart';
import '../models/placement_data.dart';

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
