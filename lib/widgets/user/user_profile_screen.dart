// lib/widgets/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String userEmail;

  // Firestore path for bookings
  final CollectionReference bookingsCollection;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.bookingsCollection,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Bookings'),
        backgroundColor: const Color(0xFF047857),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- User Info Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF14532D),
                      ),
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(Icons.person, 'Name', userName),
                    _buildDetailRow(Icons.email, 'Email', userEmail),
                    _buildDetailRow(
                      Icons.vpn_key,
                      'User ID',
                      userId.substring(0, 10) + '...',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // --- Booking History ---
            const Text(
              'Booking History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
              ),
            ),
            const Divider(height: 10),

            _buildBookingStream(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF059669), size: 20),
          const SizedBox(width: 10),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: bookingsCollection
          .orderBy('bookedAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text('Error loading bookings.');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No services booked yet!'),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Format Timestamp to a readable date
            Timestamp timestamp = data['bookedAt'] ?? Timestamp.now();
            DateTime date = timestamp.toDate();
            String formattedDate = '${date.day}/${date.month}/${date.year}';

            Color statusColor = data['status'] == 'Confirmed'
                ? Colors.green.shade700
                : (data['status'] == 'Cancelled'
                      ? Colors.red.shade700
                      : Colors.blue.shade700);

            return Card(
              margin: const EdgeInsets.only(bottom: 10.0),
              elevation: 2,
              child: ListTile(
                leading: const Icon(
                  Icons.agriculture,
                  color: Color(0xFF059669),
                ),
                title: Text(
                  data['subService'] ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Service: ${data['service'] ?? 'N/A'}\nDate: ${data['date'] ?? 'N/A'} (Booked on: $formattedDate)',
                ),
                trailing: Chip(
                  label: Text(
                    data['status'] ?? 'Pending',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: statusColor,
                ),
                isThreeLine: true,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
