// lib/widgets/service/provider_list_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProviderListSection extends StatelessWidget {
  const ProviderListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.people, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Service Providers',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Verified and experienced professionals',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Provider Cards
          _buildProviderCard(
            name: 'Ramesh Kumar',
            title: 'Agricultural Service Expert',
            rating: 4.8,
            reviewCount: 156,
            experience: '8+ years',
            distance: '15 km',
            services: ['Tractor Services', 'Soil Testing', 'Pest Control'],
            imageUrl: 'https://picsum.photos/seed/provider1/200/200.jpg',
            verified: true,
            price: '₹500/hour',
          ),
          
          const SizedBox(height: 16),
          
          _buildProviderCard(
            name: 'Sunita Devi',
            title: 'Organic Farming Specialist',
            rating: 4.9,
            reviewCount: 203,
            experience: '10+ years',
            distance: '8 km',
            services: ['Organic Certification', 'Vermicompost', 'Bio-fertilizers'],
            imageUrl: 'https://picsum.photos/seed/provider2/200/200.jpg',
            verified: true,
            price: '₹600/hour',
          ),
          
          const SizedBox(height: 16),
          
          _buildProviderCard(
            name: 'Mahesh Patel',
            title: 'Irrigation & Water Management',
            rating: 4.7,
            reviewCount: 89,
            experience: '6+ years',
            distance: '12 km',
            services: ['Drip Irrigation', 'Pump Installation', 'Water Testing'],
            imageUrl: 'https://picsum.photos/seed/provider3/200/200.jpg',
            verified: true,
            price: '₹450/hour',
          ),
          
          const SizedBox(height: 16),
          
          _buildProviderCard(
            name: 'Lakshmi Narayan',
            title: 'Crop Protection Expert',
            rating: 4.6,
            reviewCount: 124,
            experience: '7+ years',
            distance: '20 km',
            services: ['Pest Control', 'Disease Management', 'Crop Monitoring'],
            imageUrl: 'https://picsum.photos/seed/provider4/200/200.jpg',
            verified: true,
            price: '₹550/hour',
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String title,
    required double rating,
    required int reviewCount,
    required String experience,
    required String distance,
    required List<String> services,
    required String imageUrl,
    required bool verified,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Provider Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Provider Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Verification
                    Row(
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (verified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, size: 10, color: Colors.green[600]),
                                const SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Rating and Reviews
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < rating.floor() ? Icons.star : 
                              index < rating ? Icons.star_half : Icons.star_border,
                              size: 14,
                              color: index < rating ? Colors.amber : Colors.grey[300],
                            );
                          }),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$rating ($reviewCount reviews)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Experience and Distance
                    Row(
                      children: [
                        Icon(Icons.work_outline, size: 14, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          experience,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Services
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Services',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: services.map((service) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 14),
                  label: Text(
                    'Call',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: Colors.green[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    'Book',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.favorite_border, size: 16, color: Colors.green[600]),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
