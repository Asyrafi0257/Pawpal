import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_app/model/pet.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:pawpal_app/petDetails.dart';

class PublicPetListingScreen extends StatefulWidget {
  final User? user; // current logged in user (optional)
  const PublicPetListingScreen({super.key, this.user});

  @override
  State<PublicPetListingScreen> createState() => _PublicPetListingScreenState();
}

class _PublicPetListingScreenState extends State<PublicPetListingScreen> {
  List<Pet> pets = [];
  bool isLoading = false;
  String searchQuery = "";
  String filterType = "";

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  Future<void> fetchPets() async {
    setState(() => isLoading = true);

    try {
      final uri = Uri.parse("${MyConfig.baseUrl}/pawpal/api/get_all_pet.php")
          .replace(
            queryParameters: {
              if (searchQuery.isNotEmpty) 'search': searchQuery,
              if (filterType.isNotEmpty) 'filter': filterType,
            },
          );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          List<dynamic> data = jsonResponse['data'];
          setState(() {
            pets = data.map((e) => Pet.fromJson(e)).toList();
          });
        } else {
          setState(() {
            pets = [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching pets: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Public Pet Listing")),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by pet name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                searchQuery = value.trim();
                fetchPets();
              },
            ),
          ),

          // Filter dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: filterType.isEmpty ? null : filterType,
              decoration: InputDecoration(
                labelText: "Filter by Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ["Cat", "Dog", "Bird", "Rabbit", "Other"]
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                filterType = value ?? "";
                fetchPets();
              },
            ),
          ),

          const SizedBox(height: 10),

          // Pet list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pets.isEmpty
                ? const Center(child: Text("No pets found"))
                : ListView.builder(
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      final pet = pets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: pet.imagePath.isNotEmpty
                              ? Image.network(
                                  "${MyConfig.baseUrl}/pawpal/assets/${pet.imagePath.first}",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.pets),
                                )
                              : const Icon(Icons.pets, size: 40),
                          title: Text(pet.petName ?? "Unknown"),
                          subtitle: Text(
                            "${pet.petType ?? "Unknown"} • Age: ${pet.age ?? "N/A"}",
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PetDetailsScreen(
                                  pet: pet,
                                  user: widget.user,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
