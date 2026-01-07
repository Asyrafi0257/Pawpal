class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String> imagePath = [];
  String? gender; // tambahan
  String? age; // tambahan
  String? health; // tambahan
  String? lat;
  String? lng;
  String? createdAt;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? regDate;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagePath = const [],
    this.gender,
    this.age,
    this.health,
    this.lat,
    this.lng,
    this.createdAt,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.regDate,
  });

  Pet.fromJson(Map<String, dynamic> json) {
    petId = json['pet_id'];
    userId = json['user_id'];
    petName = json['pet_name'];
    petType = json['pet_type'];
    category = json['category'];
    description = json['description'];
    imagePath = json['image_path'] != null
        ? json['image_path']
              .toString()
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : [];

    gender = json['gender']; // tambahan
    age = json['age']; // tambahan
    health = json['health']; // tambahan

    lat = json['lat'];
    lng = json['lng'];
    createdAt = json['created_at'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    regDate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    data['image_path'] = imagePath.join(",");
    data['gender'] = gender; // tambahan
    data['age'] = age; // tambahan
    data['health'] = health; // tambahan
    data['lat'] = lat;
    data['lng'] = lng;
    data['created_at'] = createdAt;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['user_phone'] = userPhone;
    data['reg_date'] = regDate;
    return data;
  }
}
