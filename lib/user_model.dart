class UserModel {
  String? id;
  String? email;
  String? name;
  String? pincode;
  String? status;
  String? role;

  UserModel({this.id, this.email, this.name, this.pincode, this.status, this.role});

  // Convert a User object into a JSON map
  Map<String, dynamic> toJson() {
    return {'email': email, 'name': name, 'pincode': pincode, 'status': status, 'role': role};
  }

  // Create a User object from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email'], name: json['name'], pincode: json['pincode'], role: json['role'], status: json["status"]);
  }
}
