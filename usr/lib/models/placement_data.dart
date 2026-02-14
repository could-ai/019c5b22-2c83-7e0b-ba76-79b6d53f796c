import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AnalysisEntry {
  final String id;
  final DateTime createdAt;
  final String company;
  final String role;
  final String jdText;
  final ExtractedSkills extractedSkills;
  final List<RoundMapping> roundMapping;
  final List<ChecklistItem> checklist;
  final List<DayPlan> plan7Days;
  final List<String> questions;
  final double baseScore;
  final Map<String, String> skillConfidenceMap;
  final double finalScore;
  final String updatedAt;

  AnalysisEntry({
    required this.id,
    required this.createdAt,
    required this.company,
    required this.role,
    required this.jdText,
    required this.extractedSkills,
    required this.roundMapping,
    required this.checklist,
    required this.plan7Days,
    required this.questions,
    required this.baseScore,
    required this.skillConfidenceMap,
    required this.finalScore,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'company': company,
      'role': role,
      'jdText': jdText,
      'extractedSkills': extractedSkills.toJson(),
      'roundMapping': roundMapping.map((r) => r.toJson()).toList(),
      'checklist': checklist.map((c) => c.toJson()).toList(),
      'plan7Days': plan7Days.map((p) => p.toJson()).toList(),
      'questions': questions,
      'baseScore': baseScore,
      'skillConfidenceMap': skillConfidenceMap,
      'finalScore': finalScore,
      'updatedAt': updatedAt,
    };
  }

  factory AnalysisEntry.fromJson(Map<String, dynamic> json) {
    return AnalysisEntry(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      company: json['company'] ?? '',
      role: json['role'] ?? '',
      jdText: json['jdText'],
      extractedSkills: ExtractedSkills.fromJson(json['extractedSkills']),
      roundMapping: (json['roundMapping'] as List).map((r) => RoundMapping.fromJson(r)).toList(),
      checklist: (json['checklist'] as List).map((c) => ChecklistItem.fromJson(c)).toList(),
      plan7Days: (json['plan7Days'] as List).map((p) => DayPlan.fromJson(p)).toList(),
      questions: List<String>.from(json['questions']),
      baseScore: json['baseScore'],
      skillConfidenceMap: Map<String, String>.from(json['skillConfidenceMap']),
      finalScore: json['finalScore'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ExtractedSkills {
  final List<String> coreCS;
  final List<String> languages;
  final List<String> web;
  final List<String> data;
  final List<String> cloud;
  final List<String> testing;
  final List<String> other;

  ExtractedSkills({
    required this.coreCS,
    required this.languages,
    required this.web,
    required this.data,
    required this.cloud,
    required this.testing,
    required this.other,
  });

  Map<String, dynamic> toJson() {
    return {
      'coreCS': coreCS,
      'languages': languages,
      'web': web,
      'data': data,
      'cloud': cloud,
      'testing': testing,
      'other': other,
    };
  }

  factory ExtractedSkills.fromJson(Map<String, dynamic> json) {
    return ExtractedSkills(
      coreCS: List<String>.from(json['coreCS']),
      languages: List<String>.from(json['languages']),
      web: List<String>.from(json['web']),
      data: List<String>.from(json['data']),
      cloud: List<String>.from(json['cloud']),
      testing: List<String>.from(json['testing']),
      other: List<String>.from(json['other']),
    );
  }

  List<String> get allSkills {
    return [...coreCS, ...languages, ...web, ...data, ...cloud, ...testing, ...other];
  }
}

class RoundMapping {
  final String roundTitle;
  final List<String> focusAreas;
  final String whyItMatters;

  RoundMapping({
    required this.roundTitle,
    required this.focusAreas,
    required this.whyItMatters,
  });

  Map<String, dynamic> toJson() {
    return {
      'roundTitle': roundTitle,
      'focusAreas': focusAreas,
      'whyItMatters': whyItMatters,
    };
  }

  factory RoundMapping.fromJson(Map<String, dynamic> json) {
    return RoundMapping(
      roundTitle: json['roundTitle'],
      focusAreas: List<String>.from(json['focusAreas']),
      whyItMatters: json['whyItMatters'],
    );
  }
}

class ChecklistItem {
  final String roundTitle;
  final List<String> items;

  ChecklistItem({
    required this.roundTitle,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'roundTitle': roundTitle,
      'items': items,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      roundTitle: json['roundTitle'],
      items: List<String>.from(json['items']),
    );
  }
}

class DayPlan {
  final String day;
  final String focus;
  final List<String> tasks;

  DayPlan({
    required this.day,
    required this.focus,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'focus': focus,
      'tasks': tasks,
    };
  }

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'],
      focus: json['focus'],
      tasks: List<String>.from(json['tasks']),
    );
  }
}

// Legacy models for compatibility
class CompanyIntel {
  final String name;
  final String industry;
  final String size;
  final String type;
  final String hiringFocus;
  final List<Round> rounds;
  final DateTime timestamp;

  CompanyIntel({
    required this.name,
    required this.industry,
    required this.size,
    required this.type,
    required this.hiringFocus,
    required this.rounds,
    required this.timestamp,
  });
}

class Round {
  final String title;
  final String description;
  final String whyItMatters;
  final IconData icon;

  Round({
    required this.title,
    required this.description,
    required this.whyItMatters,
    required this.icon,
  });
}