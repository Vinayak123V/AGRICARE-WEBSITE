import 'dart:math';

class CropRecommendation {
  final String name;
  final String variety;
  final double expectedYield;
  final double estimatedCost;
  final double expectedRevenue;
  final double profitability;
  final List<String> advantages;
  final List<String> considerations;
  final String season;
  final String waterRequirement;
  final String soilPreference;
  final int growingDays;
  final double marketPrice;

  CropRecommendation({
    required this.name,
    required this.variety,
    required this.expectedYield,
    required this.estimatedCost,
    required this.expectedRevenue,
    required this.profitability,
    required this.advantages,
    required this.considerations,
    required this.season,
    required this.waterRequirement,
    required this.soilPreference,
    required this.growingDays,
    required this.marketPrice,
  });
}

class AIRecommendationService {
  static final Map<String, Map<String, dynamic>> _cropDatabase = {
    'Rice': {
      'varieties': ['Basmati', 'Sona Masoori', 'IR64', 'Pusa 1121'],
      'yield_per_acre': 2500.0,
      'cost_per_acre': 15000.0,
      'market_price': 25.0,
      'growing_days': 120,
      'water': 'High',
      'soil': 'Clay Soil',
      'seasons': ['Kharif (June–Oct)'],
      'advantages': ['High demand', 'Good market price', 'Multiple cropping possible'],
      'considerations': ['High water requirement', 'Labor intensive'],
    },
    'Wheat': {
      'varieties': ['HD 2967', 'Lokwan', 'Sharbati', 'Pusa 121'],
      'yield_per_acre': 3000.0,
      'cost_per_acre': 12000.0,
      'market_price': 22.0,
      'growing_days': 110,
      'water': 'Medium',
      'soil': 'Loamy Soil',
      'seasons': ['Rabi (Oct–March)'],
      'advantages': ['Stable market', 'Less water than rice', 'Good storage life'],
      'considerations': ['Quality depends on weather', 'Price fluctuations'],
    },
    'Cotton': {
      'varieties': ['Bt Cotton', 'Desi', 'Hybrid', 'Organic'],
      'yield_per_acre': 800.0,
      'cost_per_acre': 25000.0,
      'market_price': 85.0,
      'growing_days': 160,
      'water': 'Medium',
      'soil': 'Black Soil',
      'seasons': ['Kharif (June–Oct)'],
      'advantages': ['High profit potential', 'Long growing season', 'Industrial demand'],
      'considerations': ['High initial cost', 'Pest management critical', 'Market volatility'],
    },
    'Sugarcane': {
      'varieties': ['Co 86032', 'Co 0238', 'CoV 92101', 'CoS 767'],
      'yield_per_acre': 40000.0,
      'cost_per_acre': 35000.0,
      'market_price': 3.5,
      'growing_days': 365,
      'water': 'High',
      'soil': 'Loamy Soil',
      'seasons': ['Kharif (June–Oct)', 'Summer'],
      'advantages': ['Very high yield', 'Assured procurement', 'Long duration income'],
      'considerations': ['Long commitment', 'High water needs', 'Delayed returns'],
    },
    'Maize': {
      'varieties': ['Hybrid', 'Sweet Corn', 'Popcorn', 'Flour Corn'],
      'yield_per_acre': 3500.0,
      'cost_per_acre': 18000.0,
      'market_price': 18.0,
      'growing_days': 90,
      'water': 'Medium',
      'soil': 'Loamy Soil',
      'seasons': ['Kharif (June–Oct)', 'Rabi (Oct–March)', 'Summer'],
      'advantages': ['Flexible seasons', 'Multiple uses', 'Quick growing'],
      'considerations': ['Market price fluctuation', 'Storage requirements'],
    },
    'Pulses': {
      'varieties': ['Tur Dal', 'Urad Dal', 'Moong Dal', 'Masoor Dal'],
      'yield_per_acre': 800.0,
      'cost_per_acre': 10000.0,
      'market_price': 95.0,
      'growing_days': 85,
      'water': 'Low',
      'soil': 'Loamy Soil',
      'seasons': ['Kharif (June–Oct)', 'Rabi (Oct–March)'],
      'advantages': ['High market price', 'Nitrogen fixing', 'Low water needs'],
      'considerations': ['Lower yield', 'Price volatility', 'Labor intensive'],
    },
    'Groundnut': {
      'varieties': ['Spanish', 'Virginia', 'Runner', 'Valencia'],
      'yield_per_acre': 1500.0,
      'cost_per_acre': 15000.0,
      'market_price': 65.0,
      'growing_days': 100,
      'water': 'Medium',
      'soil': 'Sandy Soil',
      'seasons': ['Kharif (June–Oct)', 'Summer'],
      'advantages': ['Oil crop', 'Good market price', 'Drought tolerant'],
      'considerations': ['Soil specific', 'Harvesting challenges'],
    },
    'Soybean': {
      'varieties': ['JS 335', 'PK 472', 'MAUS 71', 'NRC 37'],
      'yield_per_acre': 1200.0,
      'cost_per_acre': 14000.0,
      'market_price': 45.0,
      'growing_days': 95,
      'water': 'Medium',
      'soil': 'Black Soil',
      'seasons': ['Kharif (June–Oct)'],
      'advantages': ['High protein', 'Oil extraction', 'Good export market'],
      'considerations': ['Market dependency', 'Processing required'],
    },
    'Onion': {
      'varieties': ['Red Onion', 'White Onion', 'Bellary', 'Nasik'],
      'yield_per_acre': 10000.0,
      'cost_per_acre': 20000.0,
      'market_price': 15.0,
      'growing_days': 120,
      'water': 'Medium',
      'soil': 'Loamy Soil',
      'seasons': ['Rabi (Oct–March)', 'Summer'],
      'advantages': ['High value crop', 'Good storage', 'Year-round demand'],
      'considerations': ['Price volatility', 'Storage losses', 'Market timing critical'],
    },
    'Tomato': {
      'varieties': ['Hybrid', 'Local', 'Cherry', 'Processing'],
      'yield_per_acre': 8000.0,
      'cost_per_acre': 25000.0,
      'market_price': 12.0,
      'growing_days': 110,
      'water': 'High',
      'soil': 'Loamy Soil',
      'seasons': ['Summer', 'Kharif (June–Oct)'],
      'advantages': ['Quick returns', 'High demand', 'Multiple varieties'],
      'considerations': ['Perishable', 'Price fluctuation', 'Disease prone'],
    },
    'Potato': {
      'varieties': ['Kufri', 'Chipsona', 'Local', 'Processing'],
      'yield_per_acre': 12000.0,
      'cost_per_acre': 30000.0,
      'market_price': 10.0,
      'growing_days': 90,
      'water': 'Medium',
      'soil': 'Loamy Soil',
      'seasons': ['Rabi (Oct–March)', 'Summer'],
      'advantages': ['High yield', 'Good storage', 'Staple food'],
      'considerations': ['High input cost', 'Disease management', 'Cold storage needed'],
    },
    'Chilli': {
      'varieties': ['Guntur', 'Byadagi', 'Kashmiri', 'Hybrid'],
      'yield_per_acre': 2000.0,
      'cost_per_acre': 18000.0,
      'market_price': 85.0,
      'growing_days': 140,
      'water': 'Medium',
      'soil': 'Red Soil',
      'seasons': ['Kharif (June–Oct)', 'Summer'],
      'advantages': ['High value', 'Long shelf life', 'Export potential'],
      'considerations': ['Labor intensive', 'Market quality standards', 'Pest management'],
    },
    'Turmeric': {
      'varieties': ['Suguna', 'Prabha', 'Roma', 'Local'],
      'yield_per_acre': 8000.0,
      'cost_per_acre': 22000.0,
      'market_price': 18.0,
      'growing_days': 210,
      'water': 'Medium',
      'soil': 'Red Soil',
      'seasons': ['Kharif (June–Oct)'],
      'advantages': ['High value spice', 'Good storage', 'Medicinal value'],
      'considerations': ['Long duration', 'Processing required', 'Quality dependent'],
    },
    'Garlic': {
      'varieties': ['Local', 'Improved', 'Export Quality'],
      'yield_per_acre': 3000.0,
      'cost_per_acre': 28000.0,
      'market_price': 120.0,
      'growing_days': 120,
      'water': 'Medium',
      'soil': 'Loamy Soil',
      'seasons': ['Rabi (Oct–March)'],
      'advantages': ['Very high price', 'Good storage', 'Medicinal value'],
      'considerations': ['High input cost', 'Seed cost', 'Quality sensitive'],
    },
    'Mango': {
      'varieties': ['Alphonso', 'Totapuri', 'Banginapalli', 'Kesar'],
      'yield_per_acre': 5000.0,
      'cost_per_acre': 25000.0,
      'market_price': 35.0,
      'growing_days': 150,
      'water': 'Medium',
      'soil': 'Red Soil',
      'seasons': ['Summer'],
      'advantages': ['High value fruit', 'Export potential', 'Long term income'],
      'considerations': ['Perennial crop', 'Weather dependent', 'Marketing challenges'],
    },
    'Banana': {
      'varieties': ['Grand Naine', 'Robusta', 'Poovan', 'Rasthali'],
      'yield_per_acre': 15000.0,
      'cost_per_acre': 30000.0,
      'market_price': 12.0,
      'growing_days': 365,
      'water': 'High',
      'soil': 'Loamy Soil',
      'seasons': ['Summer', 'Kharif (June–Oct)'],
      'advantages': ['High yield', 'Year-round production', 'Quick returns after planting'],
      'considerations': ['High water needs', 'Disease prone', 'Transportation costs'],
    },
    'Grapes': {
      'varieties': ['Thompson Seedless', 'Anab-e-Shahi', 'Bangalore Blue', 'Pusa Seedless'],
      'yield_per_acre': 8000.0,
      'cost_per_acre': 45000.0,
      'market_price': 45.0,
      'growing_days': 160,
      'water': 'Medium',
      'soil': 'Red Soil',
      'seasons': ['Summer'],
      'advantages': ['Very high value', 'Export potential', 'Wine industry demand'],
      'considerations': ['High investment', 'Technical expertise needed', 'Market access critical'],
    },
    'Pomegranate': {
      'varieties': ['Ganesh', 'Bhagawa', 'Ruby', 'Mridula'],
      'yield_per_acre': 6000.0,
      'cost_per_acre': 35000.0,
      'market_price': 95.0,
      'growing_days': 150,
      'water': 'Medium',
      'soil': 'Red Soil',
      'seasons': ['Summer'],
      'advantages': ['Very high price', 'Export demand', 'Drought tolerant'],
      'considerations': ['High initial cost', 'Pest management', 'Quality standards'],
    },
  };

  static final Map<String, List<String>> _regionalSpecialties = {
    'Belagavi': ['Sugarcane', 'Maize', 'Groundnut', 'Cotton'],
    'Bagalkote': ['Cotton', 'Groundnut', 'Maize', 'Pulses'],
    'Dharwad': ['Cotton', 'Groundnut', 'Maize', 'Soybean'],
    'Gadag': ['Groundnut', 'Cotton', 'Pulses', 'Sorghum'],
    'Haveri': ['Cotton', 'Maize', 'Groundnut', 'Pulses'],
    'Uttara Kannada': ['Areca nut', 'Coconut', 'Black pepper', 'Rice'],
    'Vijayapura': ['Cotton', 'Groundnut', 'Maize', 'Pulses'],
    'Bengaluru Urban': ['Vegetables', 'Flowers', 'Fruits', 'Mushroom'],
    'Bengaluru Rural': ['Vegetables', 'Millets', 'Flowers', 'Fruits'],
    'Ramanagara': ['Silk cocoon', 'Mango', 'Vegetables', 'Millets'],
    'Tumakuru': ['Groundnut', 'Millets', 'Vegetables', 'Mango'],
    'Kolar': ['Silk cocoon', 'Vegetables', 'Flowers', 'Mango'],
    'Chikkaballapura': ['Vegetables', 'Flowers', 'Millets', 'Mango'],
    'Shivamogga': ['Areca nut', 'Coconut', 'Pepper', 'Rice'],
    'Chitradurga': ['Groundnut', 'Millets', 'Pulses', 'Cotton'],
    'Davanagere': ['Cotton', 'Groundnut', 'Maize', 'Pulses'],
    'Nagpur': ['Orange', 'Cotton', 'Soybean', 'Wheat'],
    'Nashik': ['Grapes', 'Onion', 'Vegetables', 'Flowers'],
    'Pune': ['Grapes', 'Vegetables', 'Flowers', 'Fruits'],
  };

  static List<CropRecommendation> getRecommendations({
    required String district,
    required String taluk,
    required String soilType,
    required String water,
    required String season,
    required double landSize,
    required double budget,
  }) {
    List<Map<String, dynamic>> suitableCrops = [];
    
    for (var crop in _cropDatabase.entries) {
      var cropData = crop.value;
      
      // Check soil compatibility
      bool soilCompatible = _isSoilCompatible(cropData['soil'], soilType);
      
      // Check water compatibility
      bool waterCompatible = _isWaterCompatible(cropData['water'], water);
      
      // Check season compatibility
      bool seasonCompatible = cropData['seasons'].contains(season);
      
      // Check budget compatibility
      bool budgetCompatible = cropData['cost_per_acre'] <= budget;
      
      // Check regional preference
      double regionalBonus = _getRegionalBonus(crop.key, district);
      
      if (soilCompatible && waterCompatible && seasonCompatible && budgetCompatible) {
        double score = _calculateCropScore(cropData, soilCompatible, waterCompatible, regionalBonus);
        
        suitableCrops.add({
          ...cropData,
          'name': crop.key,
          'score': score,
        });
      }
    }
    
    // Sort by score and take top 5
    suitableCrops.sort((a, b) => b['score'].compareTo(a['score']));
    suitableCrops = suitableCrops.take(5).toList();
    
    // Convert to CropRecommendation objects
    return suitableCrops.map((crop) => _createCropRecommendation(crop, landSize)).toList();
  }
  
  static bool _isSoilCompatible(String cropSoil, String farmerSoil) {
    // Direct match
    if (cropSoil == farmerSoil) return true;
    
    // Compatible soil types
    Map<String, List<String>> compatibleSoils = {
      'Black Soil': ['Black Soil', 'Clay Soil', 'Loamy Soil'],
      'Red Soil': ['Red Soil', 'Loamy Soil', 'Sandy Soil'],
      'Sandy Soil': ['Sandy Soil', 'Loamy Soil'],
      'Clay Soil': ['Clay Soil', 'Black Soil', 'Loamy Soil'],
      'Loamy Soil': ['Loamy Soil', 'Black Soil', 'Red Soil', 'Clay Soil', 'Sandy Soil'],
    };
    
    return compatibleSoils[farmerSoil]?.contains(cropSoil) ?? false;
  }
  
  static bool _isWaterCompatible(String cropWater, String farmerWater) {
    Map<String, int> waterLevels = {'Low': 1, 'Medium': 2, 'High': 3};
    
    int cropLevel = waterLevels[cropWater] ?? 2;
    int farmerLevel = waterLevels[farmerWater] ?? 2;
    
    // Can grow if farmer has equal or higher water availability
    return farmerLevel >= cropLevel;
  }
  
  static double _getRegionalBonus(String crop, String district) {
    List<String> regionalCrops = _regionalSpecialties[district] ?? [];
    return regionalCrops.contains(crop) ? 1.5 : 1.0;
  }
  
  static double _calculateCropScore(
    Map<String, dynamic> cropData,
    bool soilCompatible,
    bool waterCompatible,
    double regionalBonus,
  ) {
    double baseScore = 50.0;
    
    // Profitability score (0-30 points)
    double profitability = (cropData['market_price'] * cropData['yield_per_acre']) / cropData['cost_per_acre'];
    double profitScore = (profitability / 10.0) * 30.0;
    
    // Compatibility bonuses
    if (soilCompatible) baseScore += 10;
    if (waterCompatible) baseScore += 10;
    
    // Regional bonus
    baseScore *= regionalBonus;
    
    // Add profitability
    baseScore += profitScore;
    
    // Random factor for variety (0-10 points)
    baseScore += Random().nextDouble() * 10;
    
    return baseScore;
  }
  
  static CropRecommendation _createCropRecommendation(Map<String, dynamic> crop, double landSize) {
    String variety = (crop['varieties'] as List<String>)[Random().nextInt(crop['varieties'].length)];
    
    double expectedYield = crop['yield_per_acre'] * landSize;
    double estimatedCost = crop['cost_per_acre'] * landSize;
    double expectedRevenue = expectedYield * crop['market_price'];
    double profitability = ((expectedRevenue - estimatedCost) / estimatedCost) * 100;
    
    return CropRecommendation(
      name: crop['name'],
      variety: variety,
      expectedYield: expectedYield,
      estimatedCost: estimatedCost,
      expectedRevenue: expectedRevenue,
      profitability: profitability,
      advantages: crop['advantages'],
      considerations: crop['considerations'],
      season: crop['seasons'][0],
      waterRequirement: crop['water'],
      soilPreference: crop['soil'],
      growingDays: crop['growing_days'],
      marketPrice: crop['market_price'],
    );
  }
}
