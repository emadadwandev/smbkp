import 'package:equatable/equatable.dart';

class CareerEntry extends Equatable {
  final String clubName;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;

  const CareerEntry({
    required this.clubName,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  factory CareerEntry.fromJson(Map<String, dynamic> json) {
    return CareerEntry(
      clubName: json['club_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'club_name': clubName,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'is_current': isCurrent,
    };
  }

  @override
  List<Object?> get props => [clubName, startDate, endDate, isCurrent];
}
