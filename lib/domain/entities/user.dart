import 'package:equatable/equatable.dart';
import '../value_objects/unique_id.dart';

class User extends Equatable {
  final UniqueId id;
  final String username;
  final String? avatarUrl;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, username, avatarUrl, createdAt];
}
