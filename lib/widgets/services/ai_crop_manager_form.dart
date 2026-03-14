import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_recommendation_service.dart';
import 'recommendation_results_screen.dart';

class AICropManagerScreen extends StatefulWidget {
  const AICropManagerScreen({super.key});

  @override
  State<AICropManagerScreen> createState() => _AICropManagerScreenState();
}

class _AICropManagerScreenState extends State<AICropManagerScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // FORM DATA
  String? district;
  String? taluk;
  String? soilType;
  String? water;
  String? season;

  double landSize = 0;
  double budget = 0;
  String notes = "";

  bool loading = false;

  // ---------------------------------------------------------
  // REAL-WORLD DATA
  // ---------------------------------------------------------
  final Map<String, List<String>> locationData = {
    "Belagavi": ["Belagavi", "Gokak", "Athani", "Bailhongal", "Saundatti", "Ramdurg", "Khanapur", "Hukkeri", "Raybag", "Kittur"],
    "Bagalkote": ["Bagalkote", "Badami", "Hungund", "Jamkhandi", "Mudhol", "Bilgi", "Guledgudda", "Ilkal", "Rabkavi Banhatti"],
    "Dharwad": ["Dharwad", "Hubballi", "Kalghatgi", "Kundgol", "Navalgund", "Alnavar", "Annigeri"],
    "Gadag": ["Gadag", "Ron", "Shirhatti", "Mundargi", "Nargund", "Gajendragad", "Lakshmeshwar"],
    "Haveri": ["Haveri", "Byadgi", "Hangal", "Hirekerur", "Ranebennur", "Shiggaon", "Savanur"],
    "Uttara Kannada": ["Karwar", "Ankola", "Kumta", "Bhatkal", "Sirsi", "Siddapura", "Yellapura", "Mundgod", "Haliyal", "Joida"],
    "Vijayapura": ["Vijayapura", "Indi", "Sindgi", "Basavana Bagewadi", "Muddebihal", "Talikota", "Devara Hippargi", "Chadchan"],
    "Bengaluru Urban": ["Bengaluru North", "Bengaluru South", "Bengaluru East", "Anekal", "Yelahanka"],
    "Bengaluru Rural": ["Doddaballapura", "Devanahalli", "Hoskote", "Nelamangala"],
    "Ramanagara": ["Ramanagara", "Channapatna", "Kanakapura", "Magadi"],
    "Tumakuru": ["Tumakuru", "Gubbi", "Kunigal", "Madhugiri", "Pavagada", "Sira", "Tiptur", "Turuvekere", "Chikkanayakanahalli", "Koratagere"],
    "Kolar": ["Kolar", "Bangarapet", "Malur", "Mulbagal", "Srinivaspur", "KGF"],
    "Chikkaballapura": ["Chikkaballapura", "Bagepalli", "Chintamani", "Gauribidanur", "Gudibanda", "Sidlaghatta"],
    "Shivamogga": ["Shivamogga", "Bhadravati", "Thirthahalli", "Sagara", "Shikaripura", "Soraba", "Hosanagara"],
    "Chitradurga": ["Chitradurga", "Challakere", "Hiriyur", "Holalkere", "Hosadurga", "Molakalmuru"],
    "Davanagere": ["Davanagere", "Harihara", "Honnali", "Channagiri", "Jagalur", "Nyamathi"],
    "Nagpur": ["Nagpur City", "Ramtek", "Kamptee", "Umred", "Katol", "Saoner", "Kalmeshwar"],
    "Nashik": ["Nashik City", "Malegaon", "Sinnar", "Niphad", "Trimbakeshwar", "Dindori", "Igatpuri"],
    "Pune": ["Pune City", "Baramati", "Indapur", "Shirur", "Daund", "Haveli", "Maval", "Mulshi"],
  };

  final List<Map<String, String>> soilOptions = [
    {"label": "Black Soil", "emoji": "🌑"},
    {"label": "Red Soil", "emoji": "🧱"},
    {"label": "Sandy Soil", "emoji": "🏖️"},
    {"label": "Clay Soil", "emoji": "🥣"},
    {"label": "Loamy Soil", "emoji": "🌱"},
  ];

  final List<String> waterOptions = ["Low", "Medium", "High"];

  final List<String> seasonOptions = [
    "Kharif (June–Oct)",
    "Rabi (Oct–March)",
    "Summer",
  ];

  // ---------------------------------------------------------
  // AI RECOMMENDATION
  // ---------------------------------------------------------
  Future<void> getAIRecommendations() async {
    if (district == null || taluk == null || soilType == null || water == null || season == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Get AI recommendations
      final recommendations = AIRecommendationService.getRecommendations(
        district: district!,
        taluk: taluk!,
        soilType: soilType!,
        water: water!,
        season: season!,
        landSize: landSize,
        budget: budget,
      );

      // Save to Firebase
      await FirebaseFirestore.instance.collection("farmer_analysis").add({
        "district": district,
        "taluk": taluk,
        "soilType": soilType,
        "water": water,
        "landSize": landSize,
        "season": season,
        "budget": budget,
        "notes": notes,
        "recommendations": recommendations.map((r) => {
          "name": r.name,
          "variety": r.variety,
          "profitability": r.profitability,
        }).toList(),
        "createdAt": Timestamp.now(),
      });

      if (mounted) {
        // Navigate to results screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationResultsScreen(
              recommendations: recommendations,
              district: district!,
              taluk: taluk!,
              landSize: landSize,
              budget: budget,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error getting recommendations: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ---------------------------------------------------------
  // FIREBASE SAVE (Legacy - kept for compatibility)
  // ---------------------------------------------------------
  Future<void> saveToFirebase() async {
    await getAIRecommendations();
  }

  // ---------------------------------------------------------
  // UI COMPONENTS (COMPACT)
  // ---------------------------------------------------------
  
  // Compact Dropdown
  Widget dropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChange,
    IconData icon = Icons.list,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              hint: Row(
                children: [
                  Icon(icon, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text("Select", style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: onChange,
            ),
          ),
        ),
      ],
    );
  }

  // Compact Emoji Option (Horizontal)
  Widget emojiOption({
    required String emoji,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade300,
            width: 2,
          ),
          color: selected ? Colors.green.shade50 : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Compact Text Field
  Widget _buildCompactTextField({
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
         const SizedBox(height: 4),
         SizedBox(
           height: 48,
           child: TextFormField(
            keyboardType: type,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(icon, color: Colors.green, size: 18),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
         )
      ]
    );
  }

  // ---------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF0),
      appBar: AppBar(
        title: const Text("New Analysis"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: District & Taluk
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: dropdownField(
                      label: "District",
                      items: locationData.keys.toList()..sort(),
                      value: district,
                      onChange: (v) => setState(() { district = v; taluk = null; }),
                      icon: Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dropdownField(
                      label: "Taluk",
                      items: district != null ? locationData[district]! : [],
                      value: taluk,
                      onChange: (v) => setState(() => taluk = v),
                      icon: Icons.apartment,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Row 2: Land Size & Budget
              Row(
                children: [
                  Expanded(
                    child: _buildCompactTextField(
                      label: "Land (Acres)",
                      icon: Icons.square_foot,
                      type: TextInputType.number,
                      onChanged: (v) => setState(() => landSize = double.tryParse(v) ?? 0),
                      validator: (v) => v!.isEmpty ? "Req" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactTextField(
                      label: "Budget (₹)",
                      icon: Icons.attach_money,
                      type: TextInputType.number,
                      onChanged: (v) => setState(() => budget = double.tryParse(v) ?? 0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Row 3: Water & Season
              Row(
                children: [
                   Expanded(
                    child: dropdownField(
                      label: "Water",
                      items: waterOptions,
                      value: water,
                      onChange: (v) => setState(() => water = v),
                      icon: Icons.water_drop,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: dropdownField(
                      label: "Season",
                      items: seasonOptions,
                      value: season,
                      onChange: (v) => setState(() => season = v),
                      icon: Icons.sunny,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Soil Type (Horizontal Scroll)
              const Text("Soil Type", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SizedBox(
                height: 75,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: soilOptions.map((s) => emojiOption(
                    emoji: s["emoji"]!,
                    label: s["label"]!,
                    selected: soilType == s["label"]!,
                    onTap: () => setState(() => soilType = s["label"]!),
                  )).toList(),
                ),
              ),
              if (soilType == null)
                const Text(" * Required", style: TextStyle(color: Colors.red, fontSize: 10)),

              const SizedBox(height: 12),

              // Notes
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text("Notes", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   TextFormField(
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Optional details...",
                      contentPadding: const EdgeInsets.all(10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.note_alt, color: Colors.green, size: 18),
                    ),
                    onChanged: (v) => setState(() => notes = v),
                  ),
                ],
               ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : () {
                    if (_formKey.currentState!.validate() && soilType != null) {
                      getAIRecommendations();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete all required fields"), backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Get Recommendations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}