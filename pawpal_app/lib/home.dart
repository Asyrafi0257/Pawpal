import 'dart:convert'; // DITAMBAH
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // DITAMBAH
import 'package:pawpal_app/loginpage.dart';
import 'package:pawpal_app/mainscreen.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/showAllPet.dart';
import 'package:pawpal_app/registerpet.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:pawpal_app/profilescreen.dart';

class Home extends StatefulWidget {
  User? user; // Buang 'final' supaya widget.user boleh dikemaskini

  Home({super.key, required this.user});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // --- FUNGSI REFRESH DATA ---
  // Fungsi ini mengambil data terbaru dari SharedPreferences yang telah
  // dikemaskini oleh Profilescreen tadi.
  Future<void> _refreshUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userSession = prefs.getString('user_session');
    if (userSession != null) {
      setState(() {
        Map<String, dynamic> userMap = jsonDecode(userSession);
        widget.user = User.fromJson(userMap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color.fromARGB(255, 238, 176, 83),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 238, 176, 83),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: _buildProfileImage(),
              ),
              accountName: Text(
                widget.user?.userName ?? 'Guest User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: Text(
                widget.user?.userEmail ?? 'No email',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.red),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.red),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Navigasi ke Profilescreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profilescreen(user: widget.user),
                  ),
                ).then((_) {
                  // KOD PENTING: Panggil refresh apabila user kembali dari Profile
                  _refreshUserData();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: Colors.red),
              title: const Text('Register Pet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitPetScreen(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.red),
              title: const Text('My Pets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Mainscreen(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.public, color: Colors.red),
              title: const Text('All Pets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PublicPetListingScreen(user: widget.user),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 280,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 5),
                const Text(
                  "Your pet's is here now!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 30),
                _buildMenuButton(
                  title: "Register Your Pet",
                  image: "assets/images/pet.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubmitPetScreen(user: widget.user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                _buildMenuButton(
                  title: "Pet List",
                  image: "assets/images/petList.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Mainscreen(user: widget.user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                _buildMenuButton(
                  title: "All Pets",
                  image: "assets/images/petList.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PublicPetListingScreen(user: widget.user),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (widget.user?.userImage != null && widget.user!.userImage!.isNotEmpty) {
      // Tambahkan timestamp (?v=...) supaya imej tidak tersekat pada cache lama
      final url =
          '${MyConfig.baseUrl}/pawpal/assets/profile/${widget.user!.userImage}?v=${DateTime.now().millisecondsSinceEpoch}';
      return ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: 60,
          height: 60,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 50,
              color: Color.fromARGB(255, 238, 176, 83),
            );
          },
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        size: 50,
        color: Color.fromARGB(255, 238, 176, 83),
      );
    }
  }

  Widget _buildMenuButton({
    required String title,
    required String image,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 200,
      width: 300,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: onTap,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_session'); // Buang session semasa logout
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
