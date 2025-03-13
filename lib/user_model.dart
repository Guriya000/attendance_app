class UserModel {
  String? id;
  String? email;
  String? name;
  String? pincode;

  UserModel({
    this.id,
    this.email,
    this.name,
    this.pincode,
  });

  // Convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'pincode': pincode,
    };
  }

  // Create a User object from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      pincode: json['pincode'],
    );
  }
}
