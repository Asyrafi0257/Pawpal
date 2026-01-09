import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pawpal_app/myconfig.dart';

class FoodMedicalDonationPage extends StatefulWidget {
  final String donationType;
  final String? petName;
  final String petId; // Added to match tbl_donations
  final String userId;

  const FoodMedicalDonationPage({
    super.key,
    required this.donationType,
    required this.petId,
    this.petName,
    required this.userId,
  });

  @override
  State<FoodMedicalDonationPage> createState() =>
      _FoodMedicalDonationPageState();
}

class _FoodMedicalDonationPageState extends State<FoodMedicalDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitToDatabase() async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
      '${MyConfig.baseUrl}/pawpal/api/submit_adoptions.php',
    );

    try {
      final response = await http.post(
        url,
        body: {
          "user_id":
              widget.userId, // Replace with dynamic user session ID later
          "pet_id": widget.petId, // Mapping to your table
          "donation_type": widget.donationType,
          "description": widget.petName != null
              ? "For ${widget.petName}: ${_descriptionController.text}"
              : _descriptionController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        _showSuccessDialog(data['message']);
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Thank You!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(msg, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Balik ke DonationPage
              },
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.donationType} Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "You are donating ${widget.donationType} ${widget.petName != null ? 'for ${widget.petName}' : ''}. Please provide details so we can arrange the collection.",
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Example: 2 bags of Royal Canin 5kg, Expiry: 12/2026',
                  labelText: 'Description',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[800]!, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  if (value.length < 10) return 'Please be more specific';
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _submitToDatabase();
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SUBMIT DONATION',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
