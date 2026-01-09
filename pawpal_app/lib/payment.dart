import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pawpal_app/model/pet.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:pawpal_app/resit_payment.dart';

class PaymentPage extends StatefulWidget {
  final double? initialAmount;
  final Pet pet; // Terima objek Pet
  final User user;

  const PaymentPage({
    super.key,
    this.initialAmount,
    required this.pet,
    required this.user,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    String startVal = widget.initialAmount != null
        ? widget.initialAmount!.toStringAsFixed(2)
        : '';
    _amountController = TextEditingController(text: startVal);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // --- LOGIC: SAVE TO DATABASE ---
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String url = "${MyConfig.baseUrl}/pawpal/api/submit_donation.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          "user_id": widget.user.userId, // Boleh diganti dengan ID session user
          "pet_id": widget.pet.petId.toString(),
          "donation_type": "Money",
          "amount": _amountController.text,
          "description": "Donation for ${widget.pet.petName}",
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        setState(() => _isLoading = false);

        // Pergi ke ReceiptPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPage(
              amount: _amountController.text,
              transactionId: data['donation_id'].toString(),
              petId: widget.pet.petName.toString(), // Hantar nama untuk resit
              date: DateTime.now().toString().split(' ')[0],
            ),
          ),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Payment"),
        backgroundColor: Colors.orange[400],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Payment Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "You are helping: ${widget.pet.petName}", // Papar nama pet
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    "Amount (RM)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: "RM ",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter amount' : null,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Card Number",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: _cardController,
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "XXXX XXXX XXXX XXXX",
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                    validator: (v) =>
                        (v?.length ?? 0) < 16 ? 'Invalid card' : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          decoration: const InputDecoration(
                            labelText: "MM/YY",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "CVV",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                      ),
                      child: const Text(
                        "PAY NOW",
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
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 10),
                    Text(
                      "Processing...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
