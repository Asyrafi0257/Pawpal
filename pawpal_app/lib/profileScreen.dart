import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pawpal_app/loginpage.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/myconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Profilescreen extends StatefulWidget {
  User? user;
  Profilescreen({super.key, required this.user});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? profileImage;
  bool isLoading = false;
  bool isEditing = false;

  String imageKey = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _updateTextControllers();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateTextControllers() {
    nameController.text = widget.user?.userName ?? '';
    emailController.text = widget.user?.userEmail ?? '';
    phoneController.text = widget.user?.userPhone ?? '';
  }

  Future<void> saveSession(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userSession = jsonEncode(user.toJson());
    await prefs.setString('user_session', userSession);
    log("Session updated locally");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 238, 176, 83),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: _cancelEdit,
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              if (isEditing) {
                _showSaveConfirmation();
              } else {
                setState(() => isEditing = true);
              }
            },
            child: Text(
              isEditing ? 'SAVE' : 'EDIT',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!isEditing)
            IconButton(icon: const Icon(Icons.refresh), onPressed: loadProfile),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                // 1. Buang data sesi
                await prefs.remove('user_session');

                // 2. Pergi ke LoginPage
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) =>
                        false, // Ini akan membuang semua route sebelum ini (stack dibersihkan)
                  );
                }
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : (widget.user?.userImage != null &&
                                    widget.user!.userImage!.isNotEmpty)
                              ? NetworkImage(
                                  '${MyConfig.baseUrl}/pawpal/assets/profile/${widget.user!.userImage}?v=$imageKey',
                                )
                              : null,
                          child:
                              (profileImage == null &&
                                  (widget.user?.userImage == null ||
                                      widget.user!.userImage!.isEmpty))
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        if (isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: pickimagedialog,
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color.fromARGB(
                                  255,
                                  238,
                                  176,
                                  83,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildTextField('Name', nameController, Icons.person_outline),
                  _buildTextField(
                    'Email',
                    emailController,
                    Icons.email_outlined,
                  ),
                  _buildTextField(
                    'Phone',
                    phoneController,
                    Icons.phone_android_outlined,
                  ),
                  const SizedBox(height: 20),
                  if (!isEditing) const Divider(),
                  if (isEditing) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 238, 176, 83),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Edit your profile information and tap SAVE when done',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        style: TextStyle(
          color: isEditing ? Colors.black : Colors.black87,
          fontWeight: isEditing ? FontWeight.w500 : FontWeight.normal,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: isEditing
                ? const Color.fromARGB(255, 238, 176, 83)
                : Colors.grey,
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: isEditing ? const Color.fromARGB(255, 238, 176, 83) : null,
          ),
          filled: true,
          fillColor: isEditing ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: isEditing
                  ? const Color.fromARGB(255, 238, 176, 83)
                  : Colors.grey.shade300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: isEditing
                  ? const Color.fromARGB(255, 238, 176, 83)
                  : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 238, 176, 83),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      profileImage = null;
      _updateTextControllers(); // Reset to original values
    });
  }

  void _showSaveConfirmation() {
    // Validate before saving
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Save"),
        content: const Text("Save changes to your profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              updateProfile();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void pickimagedialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Image From'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                openGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  Future<void> openGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() => profileImage = File(pickedFile.path));
    }
  }

  Future<void> updateProfile() async {
    setState(() => isLoading = true);

    try {
      String base64Image = profileImage != null
          ? base64Encode(profileImage!.readAsBytesSync())
          : '';

      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/update_profile.php'),
        body: {
          'user_id': widget.user?.userId ?? '',
          'user_name': nameController.text.trim(),
          'user_phone': phoneController.text.trim(),
          'user_email': emailController.text.trim(),
          'profile_image': base64Image,
        },
      );

      if (response.statusCode == 200) {
        log(response.body);
        var resarray = jsonDecode(response.body);

        if (resarray['status'] == 'success') {
          if (resarray['data'] != null) {
            User updatedUser = User.fromJson(resarray['data']);
            log(
              "Updated user: ${updatedUser.userName}, ${updatedUser.userEmail}, ${updatedUser.userPhone}",
            );

            setState(() {
              widget.user = updatedUser;
              imageKey = DateTime.now().millisecondsSinceEpoch.toString();
              _updateTextControllers();
              profileImage = null;
              isEditing = false;
            });

            await saveSession(updatedUser);
          } else {
            loadProfile();
            setState(() => isEditing = false);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resarray['message'] ?? "Update failed"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      log("Update Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loadProfile() async {
    setState(() => isLoading = true);
    try {
      String url =
          '${MyConfig.baseUrl}/pawpal/api/get_my_profile.php?user_id=${widget.user!.userId}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['status'] == 'success') {
          User updatedUser = User.fromJson(resarray['data'][0]);

          setState(() {
            widget.user = updatedUser;
            imageKey = DateTime.now().millisecondsSinceEpoch.toString();
            _updateTextControllers();
            profileImage = null;
          });
          await saveSession(updatedUser);
        }
      }
    } catch (e) {
      log("Load Profile Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
