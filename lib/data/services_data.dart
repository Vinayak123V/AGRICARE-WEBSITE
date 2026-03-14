// lib/data/services_data.dart

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/app_localizations.dart';
import 'services_translation_keys.dart';

// Get localized services
List<Service> getLocalizedServices(BuildContext context) {
  final loc = AppLocalizations.of(context);
  
  List<Service> services = [];
  
  for (int i = 0; i < serviceKeys.length; i++) {
    final serviceKey = serviceKeys[i];
    final icon = serviceimages[i];
    final subserviceData = serviceSubservicesKeys[serviceKey]!['subservices']!;
    
    // Create localized subservices
    List<SubService> subServices = subserviceData.map((sub) {
      return SubService(
        name: loc.translate(sub['key']!),
        price: sub['price']!,
        id: sub['key'], // Store the translation key as id
      );
    }).toList();
    
    // Get description key mapping
    String descKey;
    switch (serviceKey) {
      case 'soil_water_testing':
        descKey = 'soil_water_desc';
        break;
      case 'ploughing_services':
        descKey = 'ploughing_desc';
        break;
      case 'cultivation_services':
        descKey = 'cultivation_desc';
        break;
      case 'fertilizer_pesticides':
        descKey = 'fertilizer_desc';
        break;
      case 'borewell_services':
        descKey = 'borewell_desc';
        break;
      case 'irrigation_services':
        descKey = 'irrigation_desc';
        break;
      case 'transport_services':
        descKey = 'transport_desc';
        break;
      case 'contract_farming':
        descKey = 'contract_desc';
        break;
      default:
        descKey = 'soil_water_desc';
    }
    
    // Create localized service
    services.add(Service(
      name: loc.translate(serviceKey),
      icon: icon,
      description: loc.translate(descKey),
      subServices: subServices,
    ));
  }
  
  return services;
}

// Static services data for backward compatibility
final List<Service> servicesData = [
  {
    "name": "Soil & Water Testing",
     "image": "assets/images/soil.jpg",
    "description": "Ensure healthy soil and water",
    "subServices": [
      {"name": "Basic Soil Health Test", "price": "₹500"},
      {"name": "Comprehensive NPK Analysis", "price": "₹800"},
      {"name": "Water Salinity & pH Test", "price": "₹400"},
      {"name": "Heavy Metal Contamination Test", "price": "₹1200"},
      {"name": "Micronutrient Analysis", "price": "₹600"},
    ],
  },
  {
    "name": "Ploughing Services",
    "image": "assets/images/plough.jpg",
    "description": "Field preparation made easy",
    "subServices": [
      {"name": "Tractor Ploughing (per acre)", "price": "₹1500"},
      {"name": "Deep Ploughing", "price": "₹2000"},
      {"name": "Bullock Service", "price": "₹800"},
      {"name": "Rotavator Service", "price": "₹1800"},
      {"name": "Harrow Service", "price": "₹1200"},
      {"name": "Land Leveling", "price": "₹1600"},
    ],
  },
  {
    "name": "Cultivation Services",
   "image": "assets/images/culti.jpg",
    "description": "Complete crop cultivation",
    "subServices": [
      {"name": "Seed Sowing Services", "price": "₹800"},
      {"name": "Transplanting Services", "price": "₹1000"},
      {"name": "Weeding & Intercultivation", "price": "₹600"},
      {"name": "Mulching Services", "price": "₹700"},
      {"name": "Crop Harvesting", "price": "₹2500"},
    ],
  },
  {
    "name": "Fertilizer & Pesticides",
    "image": "assets/images/pesti.jpg",
    "description": "Boost growth safely",
    "subServices": [
      {"name": "Organic Fertilizer Supply", "price": "₹3000/quintal"},
      {"name": "NPK Fertilizer Application", "price": "₹1500"},
      {"name": "Pesticide Spraying", "price": "₹800/acre"},
      {"name": "Bio-Pesticide Solutions", "price": "₹1200"},
      {"name": "Foliar Nutrition Spray", "price": "₹500"},
    ],
  },
  {
    "name": "Borewell Services",
    "image": "assets/images/bor.jpg",
    "description": "Boost growth safely",
    "subServices": [
      {"name": "Borewell Drilling (up to 200 ft)", "price": "₹15000"},
      {"name": "Submersible Pump Installation", "price": "₹8000"},
      {"name": "Borewell Cleaning & Maintenance", "price": "₹3000"},
      {"name": "Water Yield Testing", "price": "₹2000"},
      {"name": "Motor Repair Services", "price": "₹2500"},
    ],
  },
  {
    "name": "Irrigation Services",
   "image": "assets/images/irr.jpg",
    "description": "Professional painting services",
    "subServices": [
      {"name": "Drip Irrigation Installation", "price": "₹25000/acre"},
      {"name": "Sprinkler System Setup", "price": "₹20000/acre"},
      {"name": "Flood Irrigation Management", "price": "₹800"},
      {"name": "Irrigation System Repair", "price": "₹1500"},
      {"name": "Water Pipeline Installation", "price": "₹5000"},
    ],
  },
  {
    "name": "Transport Services",
  "image": "assets/images/tra.jpg",
    "description": "Professional painting services",
    "subServices": [
      {"name": "Farm Produce Transport", "price": "₹8/km"},
      {"name": "Livestock Transportation", "price": "₹10/km"},
      {"name": "Farm Equipment Transport", "price": "₹12/km"},
      {"name": "Fertilizer & Seed Delivery", "price": "₹500"},
      {"name": "Cold Storage Transport", "price": "₹15/km"},
    ],
  },
  {
    "name": "Contract",
    "image": "assets/images/conn.webp",
    "description": "Contract",
    "subServices": [
      {"name": "Full Season Crop Management", "price": "Profit-sharing"},
      {"name": "Crop Cultivation Contract", "price": "As per agreement"},
      {"name": "Buy-back Guarantee", "price": "Market-linked"},
      {"name": "Land Lease Contract", "price": "₹50000/year"},
      {"name": "Custom Farming Services", "price": "Negotiable"},
    ],
  },
].map((data) {
  List<SubService> subs = (data['subServices'] as List)
      .map(
        (sub) => SubService(
          name: sub['name'] as String,
          price: sub['price'] as String,
        ),
      )
      .toList();
  return Service(
    name: data['name'] as String,
    icon: data['image'] as String,
    description: data['description'] as String,
    subServices: subs,
  );
}).toList();

// Define constants
const String appId = 'default-agricare-app';
// 🚨 ACTION REQUIRED: Replace with your actual Gemini API key
const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
const String geminiApiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent';
