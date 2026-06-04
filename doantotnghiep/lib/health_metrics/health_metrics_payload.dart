// health_metrics_payload.dart
class HealthMetricsPayload {
  final int userId;
  final double bloodSugar;
  final int systolic;
  final int diastolic;
  final int heartRate;

  HealthMetricsPayload({
    required this.userId,
    required this.bloodSugar,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'blood_sugar': bloodSugar,
      'systolic': systolic,
      'diastolic': diastolic,
      'heart_rate': heartRate,
    };
  }
}