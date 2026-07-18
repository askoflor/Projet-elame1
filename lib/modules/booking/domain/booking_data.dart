import 'package:flutter/material.dart';

enum PaymentMethod { orangeMoney, mtnMoMo, wave, cash }

class BookingData {
  final String serviceKey;
  final String serviceName;
  final String providerName;
  final String providerInitials;
  final Color serviceColor;
  final int urgencyLevel;
  final String urgencyLabel;
  final DateTime date;
  final String timeSlot;
  final String address;
  final String title;
  final String description;
  final int laborCost;
  final int travelCost;
  final int commission;
  final int totalCost;
  final PaymentMethod? selectedPaymentMethod;

  const BookingData({
    required this.serviceKey,
    required this.serviceName,
    required this.providerName,
    required this.providerInitials,
    required this.serviceColor,
    required this.urgencyLevel,
    required this.urgencyLabel,
    required this.date,
    required this.timeSlot,
    required this.address,
    required this.title,
    required this.description,
    this.laborCost = 10000,
    this.travelCost = 2000,
    this.commission = 600,
    this.totalCost = 12600,
    this.selectedPaymentMethod,
  });

  String get formattedDate {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get formattedDateTime => '$formattedDate · $timeSlot';
}
