import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_app/model/user.dart';
import 'dart:convert';
import 'package:pawpal_app/myconfig.dart';
import 'package:pawpal_app/model/donations.dart';

class MyDonationsPage extends StatefulWidget {
  User user;
  MyDonationsPage({super.key, required this.user});

  @override
  State<MyDonationsPage> createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  late Future<List<Donation>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFuture = _fetchDonations();
  }

  Future<List<Donation>> _fetchDonations() async {
    // 1. Semak URL yang dibina
    final String url =
        '${MyConfig.baseUrl}/pawpal/api/get_all_donation.php?user_id=${widget.user.userId}';
    print("DEBUG: Memanggil URL -> $url");

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      // 2. Semak status code (200, 404, atau 500?)
      print("DEBUG: Status Code -> ${response.statusCode}");

      // 3. Semak JSON mentah dari database
      print("DEBUG: Response Body -> ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          List<dynamic> donationsJson = data['data'];
          return donationsJson.map((json) => Donation.fromJson(json)).toList();
        } else {
          print("DEBUG: API Status Error -> ${data['message']}");
          return [];
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("DEBUG: Catch Error -> $e");
      throw Exception('Gagal menyambung ke server: $e');
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _donationsFuture = _fetchDonations();
    });
  }

  // --- UI Helper Widgets (Sama seperti kod asal anda) ---

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
      case 'approved':
      case 'success':
        return Colors.green;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Donations',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: FutureBuilder<List<Donation>>(
          future: _donationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text("${snapshot.error}", textAlign: TextAlign.center),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final donations = snapshot.data ?? [];

            if (donations.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey),
                        Text(
                          "Tiada data dijumpai dalam database.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final donation = donations[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(
                        Icons.volunteer_activism,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(
                      donation.donationType ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(donation.description ?? ''),
                    trailing: Text(
                      (donation.status ?? 'pending').toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(donation.status ?? ''),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
