import 'package:flutter/material.dart';
import 'package:pawpal_app/donation_description_page.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/payment.dart';
import 'package:pawpal_app/model/pet.dart';

class DonationPage extends StatefulWidget {
  final Pet pet;
  final User user;
  const DonationPage({super.key, required this.pet, required this.user});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDonationType;
  final List<String> _donationTypes = ['Money', 'Food', 'Medal'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contribution for ${widget.pet.petName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: _selectedDonationType,
                decoration: const InputDecoration(
                  labelText: 'Donation Type',
                  border: OutlineInputBorder(),
                ),
                items: _donationTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDonationType = value),
                validator: (value) =>
                    value == null ? 'Please select a type' : null,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDonationType == 'Money') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentPage(pet: widget.pet, user: widget.user),
                          ),
                        );
                      } else {
                        // Pass both petName for display and petId for the database
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodMedicalDonationPage(
                              donationType: _selectedDonationType!,
                              petName: widget.pet.petName,
                              petId: widget.pet.petId.toString(),
                              userId: widget.user.userId.toString(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                  ),
                  child: const Text(
                    'Continue',
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
