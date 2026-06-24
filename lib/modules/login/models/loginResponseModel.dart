class LoginResponseModel {
  String? jwt;
  User? user;

  LoginResponseModel({this.jwt, this.user});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    jwt = json['jwt'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jwt'] = this.jwt;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? documentId;
  String? username;
  String? email;
  String? provider;
  bool? confirmed;
  bool? blocked;
  String? nip;
  String? name;
  String? birthDate;
  String? createdAt;
  String? updatedAt;
  String? publishedAt;

  User({
    this.id,
    this.documentId,
    this.username,
    this.email,
    this.provider,
    this.confirmed,
    this.blocked,
    this.nip,
    this.name,
    this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    documentId = json['documentId'];
    username = json['username'];
    email = json['email'];
    provider = json['provider'];
    confirmed = json['confirmed'];
    blocked = json['blocked'];
    nip = json['nip'];
    name = json['name'];
    birthDate = json['birthDate'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    publishedAt = json['publishedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['documentId'] = this.documentId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['provider'] = this.provider;
    data['confirmed'] = this.confirmed;
    data['blocked'] = this.blocked;
    data['nip'] = this.nip;
    data['name'] = this.name;
    data['birthDate'] = this.birthDate;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['publishedAt'] = this.publishedAt;
    return data;
  }
}
