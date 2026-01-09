class Donation {
  String? donationId;
  String? userId;
  String? petId;
  String? donationType;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;

  Donation({
    this.donationId,
    this.userId,
    this.petId,
    this.donationType,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Menukarkan JSON dari API kepada Objek Donation
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      donationId: json['donation_id']?.toString(),
      userId: json['user_id']?.toString(),
      petId: json['pet_id']?.toString(),
      donationType: json['donation_type'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Menukarkan Objek Donation kepada JSON (untuk hantar ke API jika perlu)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['donation_id'] = donationId;
    data['user_id'] = userId;
    data['pet_id'] = petId;
    data['donation_type'] = donationType;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
