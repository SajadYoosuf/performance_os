import 'package:equatable/equatable.dart';

/// User entity.
class UserEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final List<String> primaryDomains;
  final int dailyFocusHours;
  final String peakEnergyTime; // morning, afternoon, evening
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.primaryDomains = const ['work'],
    this.dailyFocusHours = 6,
    this.peakEnergyTime = 'morning',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email];
}
