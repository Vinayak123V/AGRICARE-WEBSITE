import 'package:flutter/material.dart';
import 'ai_recommendation_service.dart';

class RecommendationResultsScreen extends StatelessWidget {
  final List<CropRecommendation> recommendations;
  final String district;
  final String taluk;
  final double landSize;
  final double budget;

  const RecommendationResultsScreen({
    super.key,
    required this.recommendations,
    required this.district,
    required this.taluk,
    required this.landSize,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FDF0),
      appBar: AppBar(
        title: const Text("AI Recommendations"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "$district, $taluk",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.square_foot, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text("Land: ${landSize.toStringAsFixed(1)} acres"),
                    const Spacer(),
                    Icon(Icons.attach_money, color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text("Budget: ₹${budget.toStringAsFixed(0)}"),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Found ${recommendations.length} suitable crops for your farm",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Recommendations List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                return _buildRecommendationCard(recommendation, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(CropRecommendation recommendation, int rank) {
    Color rankColor = _getRankColor(rank);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Rank
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "$rank",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Variety: ${recommendation.variety}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recommendation.profitability > 50
                        ? Colors.green.shade100
                        : recommendation.profitability > 20
                            ? Colors.orange.shade100
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${recommendation.profitability.toStringAsFixed(1)}%",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: recommendation.profitability > 50
                          ? Colors.green.shade800
                          : recommendation.profitability > 20
                              ? Colors.orange.shade800
                              : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Summary
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        "Expected Yield",
                        "${recommendation.expectedYield.toStringAsFixed(0)} kg",
                        Icons.agriculture,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        "Revenue",
                        "₹${recommendation.expectedRevenue.toStringAsFixed(0)}",
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        "Investment",
                        "₹${recommendation.estimatedCost.toStringAsFixed(0)}",
                        Icons.money,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        "Duration",
                        "${recommendation.growingDays} days",
                        Icons.schedule,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Requirements
                Row(
                  children: [
                    _buildRequirementChip(
                      "Soil",
                      recommendation.soilPreference,
                      Icons.landscape,
                      Colors.brown,
                    ),
                    const SizedBox(width: 8),
                    _buildRequirementChip(
                      "Water",
                      recommendation.waterRequirement,
                      Icons.water_drop,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildRequirementChip(
                      "Season",
                      recommendation.season,
                      Icons.sunny,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Advantages and Considerations
                if (recommendation.advantages.isNotEmpty) ...[
                  _buildSectionTitle("Advantages", Icons.thumb_up, Colors.green),
                  const SizedBox(height: 4),
                  _buildBulletPoints(recommendation.advantages),
                  const SizedBox(height: 12),
                ],
                
                if (recommendation.considerations.isNotEmpty) ...[
                  _buildSectionTitle("Considerations", Icons.warning, Colors.orange),
                  const SizedBox(height: 4),
                  _buildBulletPoints(recommendation.considerations),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementChip(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoints(List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) => Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                point,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Colors.green.shade600;
    }
  }
}
