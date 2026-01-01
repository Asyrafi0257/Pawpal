import 'dart:convert';

class Mypets {
  String? thumbnail;
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? descriptions;
  List<String>? imagePath;
  String? lat;
  String? lng;
  String? createAt;

  // Added user info
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userRegdate;

  Mypets({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.descriptions,
    this.imagePath,
    this.thumbnail,
    this.lat,
    this.lng,
    this.createAt,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userRegdate,
  });

  Mypets.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    descriptions = json['descriptions'];
    // Decode image_path JSON array
    if (json['image_path'] != null) {
      if (json['image_path'] is String) {
        try {
          imagePath = List<String>.from(jsonDecode(json['image_path']));
        } catch (e) {
          imagePath = [json['image_path']];
        }
      } else if (json['image_path'] is List) {
        imagePath = List<String>.from(json['image_path']);
      }
    }
    // Get thumbnail from API or fallback to first imagePath
    if (json['thumbnail'] != null && json['thumbnail'] is String) {
      thumbnail = json['thumbnail'];
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      thumbnail = imagePath![0];
    } else {
      thumbnail = null;
    }
    lat = json['lat'];
    lng = json['lng'];
    createAt = json['create_at'];

    // Mapping user fields
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    userRegdate = json['user_regdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['descriptions'] = descriptions;
    // Encode imagePath as JSON string
    data['image_path'] = imagePath != null ? jsonEncode(imagePath) : null;
    data['thumbnail'] = thumbnail;
    data['lat'] = lat;
    data['lng'] = lng;
    data['create_at'] = createAt;

    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['user_phone'] = userPhone;
    data['user_regdate'] = userRegdate;

    return data;
  }
}
