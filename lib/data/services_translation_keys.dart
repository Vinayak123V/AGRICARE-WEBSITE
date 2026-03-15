// lib/data/services_translation_keys.dart

// Subservice translation keys mapping
const Map<String, Map<String, List<Map<String, String>>>> serviceSubservicesKeys = {
  'soil_water_testing': {
    'subservices': [
      {'key': 'basic_soil_test', 'price': '₹500'},
      {'key': 'npk_analysis', 'price': '₹800'},
      {'key': 'water_salinity', 'price': '₹400'},
      {'key': 'heavy_metal', 'price': '₹1200'},
      {'key': 'micronutrient', 'price': '₹600'},
    ],
  },
  'ploughing_services': {
    'subservices': [
      {'key': 'tractor_ploughing', 'price': '₹1500'},
      {'key': 'deep_ploughing', 'price': '₹2000'},
      {'key': 'bullock_service', 'price': '₹800'},
      {'key': 'rotavator', 'price': '₹1800'},
      {'key': 'harrow', 'price': '₹1200'},
      {'key': 'land_leveling', 'price': '₹1600'},
    ],
  },
  'cultivation_services': {
    'subservices': [
      {'key': 'seed_sowing', 'price': '₹800'},
      {'key': 'transplanting', 'price': '₹1000'},
      {'key': 'weeding', 'price': '₹600'},
      {'key': 'mulching', 'price': '₹700'},
      {'key': 'harvesting', 'price': '₹2500'},
    ],
  },
  'fertilizer_pesticides': {
    'subservices': [
      {'key': 'organic_fertilizer', 'price': '₹3000/quintal'},
      {'key': 'npk_application', 'price': '₹1500'},
      {'key': 'pesticide_spray', 'price': '₹800/acre'},
      {'key': 'bio_pesticide', 'price': '₹1200'},
      {'key': 'foliar_nutrition', 'price': '₹500'},
    ],
  },
  'borewell_services': {
    'subservices': [
      {'key': 'borewell_drilling', 'price': '₹15000'},
      {'key': 'pump_installation', 'price': '₹8000'},
      {'key': 'borewell_cleaning', 'price': '₹3000'},
      {'key': 'water_testing', 'price': '₹2000'},
      {'key': 'motor_repair', 'price': '₹2500'},
    ],
  },
  'irrigation_services': {
    'subservices': [
      {'key': 'drip_irrigation', 'price': '₹25000/acre'},
      {'key': 'sprinkler_system', 'price': '₹20000/acre'},
      {'key': 'flood_irrigation', 'price': '₹800'},
      {'key': 'irrigation_repair', 'price': '₹1500'},
      {'key': 'pipeline', 'price': '₹5000'},
    ],
  },
  'transport_services': {
    'subservices': [
      {'key': 'farm_transport', 'price': '₹8/km'},
      {'key': 'livestock_transport', 'price': '₹10/km'},
      {'key': 'equipment_transport', 'price': '₹12/km'},
      {'key': 'fertilizer_delivery', 'price': '₹500'},
      {'key': 'cold_storage', 'price': '₹15/km'},
    ],
  },
  'contract_farming': {
    'subservices': [
      {'key': 'full_season', 'price': 'Profit-sharing'},
      {'key': 'crop_contract', 'price': 'As per agreement'},
      {'key': 'buyback', 'price': 'Market-linked'},
      {'key': 'land_lease', 'price': '₹50000/year'},
      {'key': 'custom_farming', 'price': 'Negotiable'},
    ],
  },
};

// Service name to key mapping
const List<String> serviceKeys = [
  'soil_water_testing',
  'ploughing_services',
  'cultivation_services',
  'fertilizer_pesticides',
  'borewell_services',
  'irrigation_services',
  'transport_services',
  'contract_farming',
];

const List<String> serviceimages = [
  'assets/images/soil.jpg',
  'assets/images/plough.jpg',
  'assets/images/culti.jpg',
  'assets/images/pesti.jpg',
  'assets/images/bor.jpg',
  'assets/images/irr.jpg',
  'assets/images/tra.jpg',
  'assets/images/conn.webp',
];
