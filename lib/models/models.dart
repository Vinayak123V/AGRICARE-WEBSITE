// lib/models/models.dart

class SubService {
  final String name;
  final String price;
  final String? id; // Translation key identifier

  SubService({
    required this.name,
    required this.price,
    this.id,
  });
}

class Service {
  final String name;
  final String icon;
  final String description;
  final List<SubService> subServices;

  Service({
    required this.name,
    required this.icon,
    required this.description,
    required this.subServices,
  });
}

class AuthState {
  final bool isAuthenticated;
  final String? user;

  AuthState({
    required this.isAuthenticated,
    this.user,
  });
}

class NotificationState {
  final bool show;
  final String message;
  final String type; // 'success' or 'error'

  NotificationState({
    this.show = false,
    this.message = '',
    this.type = 'success',
  });

  NotificationState copyWith({bool? show, String? message, String? type}) {
    return NotificationState(
      show: show ?? this.show,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}
