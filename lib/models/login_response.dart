class LoginResponse {
  const LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.name,
    required this.nickname,
    required this.avatar,
    required this.phoneMask,
    required this.tenantId,
    required this.tenantName,
    required this.logo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      phoneMask: json['phoneMask'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      logo: json['logo'] as String? ?? '',
    );
  }

  final String token;
  final String refreshToken;
  final String userId;
  final String customerId;
  final String customerName;
  final String name;
  final String nickname;
  final String avatar;
  final String phoneMask;
  final String tenantId;
  final String tenantName;
  final String logo;
}

