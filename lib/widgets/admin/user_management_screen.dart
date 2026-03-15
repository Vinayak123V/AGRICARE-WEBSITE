// lib/widgets/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all'; // 'all', 'farmers', 'vendors'
  Stream<QuerySnapshot>? _usersStream;

  @override
  void initState() {
    super.initState();
    _updateUsersStream();
  }

  void _updateUsersStream() {
    setState(() {
      switch (_selectedFilter) {
        case 'farmers':
          _usersStream = UserService.farmersStream();
          break;
        case 'vendors':
          _usersStream = UserService.vendorsStream();
          break;
        default:
          _usersStream = FirebaseFirestore.instance
              .collection('users')
              .orderBy('createdAt', descending: true)
              .snapshots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF1FDF0),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, licence number, or RC number...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF047857)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF047857)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF047857), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      _performSearch(value);
                    } else {
                      _updateUsersStream();
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Filter Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterButton('All Users', 'all'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterButton('Farmers', 'farmers'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterButton('Vendors', 'vendors'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // User Statistics
          FutureBuilder<Map<String, int>>(
            future: UserService.getUserStatistics(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              
              final stats = snapshot.data!;
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('Total Users', stats['totalUsers']!, Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Farmers', stats['totalFarmers']!, Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard('Vendors', stats['totalVendors']!, Colors.orange),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Users List
          Expanded(
            child: _usersStream != null
                ? StreamBuilder<QuerySnapshot>(
                    stream: _usersStream!,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final users = snapshot.data!.docs;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final userData = users[index].data() as Map<String, dynamic>;
                          final userId = users[index].id;
                          return _buildUserCard(userData, userId);
                        },
                      );
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, String filter) {
    final isSelected = _selectedFilter == filter;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
          _updateUsersStream();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF047857) : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.grey[700],
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> userData, String userId) {
    final userType = userData['userType'] as String? ?? 'unknown';
    final isVendor = userType == 'vendor';
    final name = userData['displayName'] as String? ?? 'Unknown';
    final email = userData['email'] as String? ?? 'No email';
    final createdAt = userData['createdAt'] as Timestamp?;
    final licenceNumber = userData['licenceNumber'] as String?;
    final rcNumber = userData['rcNumber'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                // User Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVendor ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isVendor ? 'VENDOR' : 'FARMER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Status Indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: userData['status'] == 'active' ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // User Info
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isVendor ? Colors.orange : Colors.green,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Vendor-specific fields
            if (isVendor && (licenceNumber != null || rcNumber != null)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (licenceNumber != null) ...[
                      Text(
                        'Licence Number:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        licenceNumber!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (rcNumber != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'RC Number:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rcNumber!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            // Footer
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  createdAt != null
                      ? 'Joined: ${_formatDate(createdAt!)}'
                      : 'Join date unknown',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Text(
                  'ID: ${userId.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _performSearch(String searchTerm) async {
    try {
      final results = await UserService.searchUsers(searchTerm);
      // Update UI with search results
      setState(() {
        _usersStream = Stream.value(results);
      });
    } catch (e) {
      print('Search error: $e');
    }
  }
}
