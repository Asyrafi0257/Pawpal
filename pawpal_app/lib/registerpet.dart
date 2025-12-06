import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pawpal_app/model/user.dart';
import 'package:pawpal_app/myconfig.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  // list pilihan
  List<String> petTypes = ['Cat', 'Dog', 'Bird', 'Rabbit'];
  List<String> submissionCategory = [
    'Adoption',
    'Donation Request',
    'Help/Rescue',
  ];

  String selectedpets = 'Cat';
  String selectedcategory = 'Adoption';

  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  // single-file legacy (tidak digunakan utk multi) - boleh dikeluarkan
  File? image;
  Uint8List? webImage; // for web single image (not used)

  // multi-image state
  List<File> images = []; // mobile
  List<Uint8List> webImages = []; // web

  Position? mypostion; // boleh null
  String address = "";
  late double height, width;

  @override
  void dispose() {
    petNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pet Registration Submitted')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========= Multi-image grid =========
                  const Text(
                    'Images (max 3)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // existing images (mobile or web)
                      ..._buildImagePreviews(),

                      // Add button if less than 3
                      if ((kIsWeb ? webImages.length : images.length) < 3)
                        GestureDetector(
                          onTap: () {
                            if (kIsWeb) {
                              pickMultiImagesWeb();
                            } else {
                              pickimagedialog();
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 40),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // pet name
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // dropdowns
                  SizedBox(
                    width: 350,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 130,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Pet Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            items: petTypes.map((String pets) {
                              return DropdownMenuItem<String>(
                                value: pets,
                                child: Text(
                                  pets,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == null) return;
                              setState(() {
                                selectedpets = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 3),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            items: submissionCategory.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue == null) return;
                              setState(() {
                                selectedcategory = newValue;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // location field with icon
                  TextField(
                    maxLines: 3,
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          try {
                            mypostion = await _determinePosition();
                            // get placemark
                            List<Placemark> placemarks =
                                await placemarkFromCoordinates(
                                  mypostion!.latitude,
                                  mypostion!.longitude,
                                );
                            Placemark place = placemarks[0];
                            addressController.text =
                                "${place.name ?? ''},\n${place.street ?? ''},\n${place.postalCode ?? ''}, ${place.locality ?? ''},\n${place.administrativeArea ?? ''}, ${place.country ?? ''}";
                            setState(() {});
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Location error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // submit
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showSubmitDialog();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 20.0,
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build preview widgets for images
  List<Widget> _buildImagePreviews() {
    List<Widget> previews = [];
    if (kIsWeb) {
      for (int i = 0; i < webImages.length; i++) {
        previews.add(_imagePreviewWidgetWeb(i));
      }
    } else {
      for (int i = 0; i < images.length; i++) {
        previews.add(_imagePreviewWidgetMobile(i));
      }
    }
    return previews;
  }

  Widget _imagePreviewWidgetMobile(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(images[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                images.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePreviewWidgetWeb(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: MemoryImage(webImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                webImages.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Image pickers ----------

  // Dialog for mobile: camera or gallery
  void pickimagedialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Image'),
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
                  pickMultiImagesMobile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Open camera (adds 1 image)
  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      if (kIsWeb) {
        if (webImages.length < 3) {
          webImages.add(await pickedFile.readAsBytes());
          setState(() {});
        }
      } else {
        File file = File(pickedFile.path);
        // optional crop on mobile
        File? cropped = await cropImageForFile(file);
        if (cropped != null) {
          if (images.length < 3) {
            images.add(cropped);
            setState(() {});
          }
        } else {
          // if no crop result, still add original
          if (images.length < 3) {
            images.add(file);
            setState(() {});
          }
        }
      }
    }
  }

  // Gallery multi pick mobile
  Future<void> pickMultiImagesMobile() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        if (images.length >= 3) break;
        File f = File(file.path);
        // crop each selected image (optional)
        File? cropped = await cropImageForFile(f);
        if (cropped != null) {
          images.add(cropped);
        } else {
          images.add(f);
        }
      }
      setState(() {});
    }
  }

  // Web multi image pick
  Future<void> pickMultiImagesWeb() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        if (webImages.length >= 3) break;
        webImages.add(await file.readAsBytes());
      }
      setState(() {});
    }
  }

  // Cropper helper (mobile only)
  Future<File?> cropImageForFile(File file) async {
    if (kIsWeb) return null;
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Please Crop Your Image',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Cropper'),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      // ignore crop errors
    }
    return null;
  }

  // ---------- Location helper ----------
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  // ---------- Submit flow ----------
  void showSubmitDialog() {
    // Pet Name validation
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter pet name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Image validation: require at least 1 image
    if (!kIsWeb && images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 1 image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (kIsWeb && webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 1 image"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Description
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Confirm dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Service'),
          content: const Text('Are you sure you want to submit this service?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                submitPet();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void submitPet() async {
    // convert images -> base64 list
    List<String> base64Images = [];

    try {
      if (kIsWeb) {
        base64Images = webImages.map((img) => base64Encode(img)).toList();
      } else {
        for (var f in images) {
          List<int> bytes = await f.readAsBytes();
          base64Images.add(base64Encode(bytes));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image encode error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String petName = petNameController.text.trim();
    String description = descriptionController.text.trim();

    // prepare latitude/longitude (if available)
    String lat = mypostion?.latitude.toString() ?? "";
    String lng = mypostion?.longitude.toString() ?? "";

    // show simple loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
        body: {
          'userid': widget.user?.userId ?? '',
          'name': petName,
          'types': selectedpets,
          'category': selectedcategory,
          'descriptions': description,
          'latitude': lat,
          'longitude': lng,
          // images as JSON encoded array of base64 strings
          'images': jsonEncode(base64Images),
        },
      );
      print('Server response: ${response.body}');

      Navigator.pop(context); // remove loading dialog

      if (response.statusCode == 200) {
        var resarray = jsonDecode(response.body);
        if (resarray['status'] == 'success') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Service submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // close submit screen
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resarray['message'] ?? 'Submission failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Server error: ${response.statusCode} ${response.reasonPhrase}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // remove loading dialog if still open
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
