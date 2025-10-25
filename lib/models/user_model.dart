class MerchantUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? dateOfBirth;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MerchantUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.dateOfBirth,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory MerchantUser.fromJson(Map<String, dynamic> json) {
    return MerchantUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImage: json['profileImage'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'dateOfBirth': dateOfBirth,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MerchantUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? dateOfBirth,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AuthResponse {
  final MerchantUser user;
  final String token;
  final bool needsProfileCompletion;

  AuthResponse({
    required this.user,
    required this.token,
    required this.needsProfileCompletion,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: MerchantUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      needsProfileCompletion: json['needsProfileCompletion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'needsProfileCompletion': needsProfileCompletion,
    };
  }
}
