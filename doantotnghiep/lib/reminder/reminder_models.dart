class Medication {
  final int id;
  final String medicationName;
  final String? medicationCategory;

  Medication({required this.id, required this.medicationName, this.medicationCategory});

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      medicationName: json['medication_name'],
      medicationCategory: json['medication_category'],
    );
  }
}

class ReminderItem {
  final int id;
  final int userId;
  final int? medicationDictionaryId; // 🟢 1. ĐỔI THÀTH int? (cho phép null)
  final String title;
  final String dosage;
  final String reminderTime;
  final int isActive;

  ReminderItem({
    required this.id,
    required this.userId,
    this.medicationDictionaryId, // 🟢 2. Bỏ required đi
    required this.title,
    required this.dosage,
    required this.reminderTime,
    required this.isActive,
  });

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      // 🟢 3. SỬA CHỖ NÀY: Dùng json['medication_dictionary_id'] trực tiếp (không ép sang int nếu nó null)
      medicationDictionaryId: json['medication_dictionary_id'], 
      title: json['title'] ?? '',
      dosage: json['dosage'] ?? '',
      reminderTime: json['reminder_time'] ?? '',
      isActive: json['is_active'] ?? 1,
    );
  }
}