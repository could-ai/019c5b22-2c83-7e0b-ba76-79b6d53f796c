import 'package:flutter/material.dart';

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
