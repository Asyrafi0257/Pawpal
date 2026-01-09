import 'package:flutter/material.dart';

class ReceiptPage extends StatelessWidget {
  final String amount;
  final String date;
  final String transactionId;
  final String
  petId; // Gunakan petId supaya sepadan dengan hantaran PaymentPage

  const ReceiptPage({
    super.key,
    required this.amount,
    required this.date,
    required this.transactionId,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Transaction Receipt"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 10),
                  const Text(
                    "Payment Successful!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "RM $amount",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(height: 40, thickness: 1),
                  ),
                  _buildReceiptItem("Pet Helped", petId),
                  _buildReceiptItem("Date", date),
                  _buildReceiptItem("Transaction ID", "#$transactionId"),
                  _buildReceiptItem("Status", "Completed"),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Thank you for your kindness! Your donation helps provide food and medical care.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "BACK TO HOME",
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
    );
  }

  Widget _buildReceiptItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Sejajarkan ke atas jika teks panjang
        children: [
          // Label kekal di kiri
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(width: 10), // Jarak antara label dan value
          // Gunakan Expanded supaya value boleh ambil ruang baki
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right, // Tolak teks ke kanan
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                overflow: TextOverflow
                    .visible, // Atau TextOverflow.ellipsis jika mahu potong
              ),
            ),
          ),
        ],
      ),
    );
  }
}
