class MetricPoint {
  final String date;
  final double? bloodSugar;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;

  MetricPoint({
    required this.date,
    this.bloodSugar,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
  });

  factory MetricPoint.fromJson(Map<String, dynamic> json) {
    return MetricPoint(
      date: json['date'] ?? '',
      bloodSugar: json['blood_sugar'] != null ? (json['blood_sugar'] as num).toDouble() : null,
      systolicBp: json['systolic_bp'],
      diastolicBp: json['diastolic_bp'],
      heartRate: json['heart_rate'],
    );
  }
}