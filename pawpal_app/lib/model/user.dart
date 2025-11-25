class User {
  String? userId;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userPassword;
  String? userRegdate;

  User({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userPassword,
    this.userRegdate,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    userPhone = json['user_phone'];
    userPassword = json['user_password'];
    userRegdate = json['reg_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['user_phone'] = userPhone;
    data['user_password'] = userPassword;
    data['reg_date'] = userRegdate;
    return data;
  }
}
