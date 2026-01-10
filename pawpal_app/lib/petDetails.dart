import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal_app/donationpage.dart';
import 'package:pawpal_app/model/pet.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;
  final User? user; // Current logged in user

  const PetDetailsScreen({super.key, required this.pet, this.user});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late double screenWidth, screenHeight;
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth > 600) {
      screenWidth = 600;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pet.petName ?? 'Pet Details',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildImageGallery(),

                // Pet Information
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Name
                      Text(
                        widget.pet.petName ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Type and Category Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.pet.petType ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellow[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.pet.category ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Pet Details Section
                      const Text(
                        'Pet Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Gender
                      if (widget.pet.gender != null)
                        Text(
                          'Gender : ${widget.pet.gender!}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(width: 10),

                      // Age
                      if (widget.pet.age != null)
                        Text(
                          'Age : ${widget.pet.age!}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(width: 10),

                      // Health
                      if (widget.pet.health != null)
                        Text(
                          'Health : ${widget.pet.health!}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      const SizedBox(width: 15),

                      // Description Section
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.pet.description ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Posted By Section
                      const Text(
                        'Posted By',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Owner Name
                      _buildInfoRow(
                        Icons.person,
                        'Owner',
                        widget.pet.userName ?? 'Unknown',
                      ),
                      const SizedBox(height: 10),

                      // Owner Email
                      _buildInfoRow(
                        Icons.email,
                        'Email',
                        widget.pet.userEmail ?? 'Not available',
                      ),
                      const SizedBox(height: 10),

                      // Owner Phone
                      _buildInfoRow(
                        Icons.phone,
                        'Phone',
                        widget.pet.userPhone ?? 'Not available',
                      ),
                      const SizedBox(height: 24),

                      // Location Section (if available)
                      if (widget.pet.lat != null && widget.pet.lng != null) ...[
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on,
                          'Coordinates',
                          '${widget.pet.lat}, ${widget.pet.lng}',
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Request to Adopt Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please login to request adoption',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              _showAdoptionRequestForm();
                            }
                          },
                          icon: const Icon(Icons.pets),
                          label: const Text(
                            'Request to Adopt',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // donation to adopt Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please login to request adoption',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DonationPage(
                                    user: widget.user!,
                                    pet: widget.pet,
                                  ), // Nama class page baru anda
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.volunteer_activism),
                          label: const Text(
                            'Donation to Adopt',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Buttons
                      Row(
                        children: [
                          if (widget.pet.userPhone != null &&
                              widget.pet.userPhone!.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _makePhoneCall(widget.pet.userPhone!),
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          if (widget.pet.userPhone != null &&
                              widget.pet.userPhone!.isNotEmpty &&
                              widget.pet.userEmail != null &&
                              widget.pet.userEmail!.isNotEmpty)
                            const SizedBox(width: 12),
                          if (widget.pet.userEmail != null &&
                              widget.pet.userEmail!.isNotEmpty)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _sendEmail(widget.pet.userEmail!),
                                icon: const Icon(Icons.email),
                                label: const Text('Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    List<String> images = widget.pet.imagePath;

    if (images.isEmpty) {
      return Container(
        width: screenWidth,
        height: screenHeight * 0.4,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Main Image
        GestureDetector(
          onTap: () {
            // Show full screen image
            _showFullScreenImage(currentImageIndex);
          },
          child: Container(
            width: screenWidth,
            height: screenHeight * 0.4,
            color: Colors.grey[200],
            child: Image.network(
              '${MyConfig.baseUrl}/pawpal/assets/${images[currentImageIndex]}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                );
              },
            ),
          ),
        ),

        // Thumbnail Gallery (if multiple images)
        if (images.length > 1)
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: currentImageIndex == index
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        '${MyConfig.baseUrl}/pawpal/assets/${images[index]}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(int index) {
    List<String> images = widget.pet.imagePath;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(
                '${MyConfig.baseUrl}/pawpal/assets/${images[index]}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAdoptionRequestForm() {
    final TextEditingController messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Request to Adopt',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are requesting to adopt: ${widget.pet.petName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Why do you want to adopt this pet?',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText:
                          'Share your motivation for adopting this pet...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your motivation message';
                      }
                      if (value.trim().length < 20) {
                        return 'Message should be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  _submitAdoptionRequest(messageController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Request'),
            ),
          ],
        );
      },
    );
  }

  void _submitAdoptionRequest(String message) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_adoptions.php'),
        body: {
          'pet_id': widget.pet.petId.toString(),
          'adopter_id': widget.user!.userId.toString(),
          'owner_id': widget.pet.userId.toString(),
          'message': message,
        },
      );

      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (mounted) {
          if (jsonResponse['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adoption request submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  jsonResponse['message'] ?? 'Failed to submit request',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Server error. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry about ${widget.pet.petName}',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }
}
