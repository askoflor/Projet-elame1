import 'package:flutter/material.dart';

class ProviderModel {
  final String initials;
  final String name;
  final String specialty;
  final String location;
  final int interventions;
  final bool isAvailable;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isCertified;
  final String price;
  final Color avatarColor;
  final Color avatarBgColor;
  final String about;
  final List<String> skills;
  final List<Map<String, String>> certifications;
  final List<ReviewModel> reviews;

  const ProviderModel({
    required this.initials,
    required this.name,
    required this.specialty,
    required this.location,
    required this.interventions,
    required this.isAvailable,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.isCertified,
    required this.price,
    required this.avatarColor,
    required this.avatarBgColor,
    this.about = '',
    this.skills = const [],
    this.certifications = const [],
    this.reviews = const [],
  });

  String get successRate => '98%';
  String get formattedInterventions => '$interventions';
  String get formattedRating => rating.toStringAsFixed(1);
}

class ReviewModel {
  final String initials;
  final String name;
  final String date;
  final int rating;
  final String text;

  const ReviewModel({
    required this.initials,
    required this.name,
    required this.date,
    required this.rating,
    required this.text,
  });
}
