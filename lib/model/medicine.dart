class Medicine {
  final List<dynamic>? notificationId;
  final String? medicineName;
  final int? dosage;
  final int? interval;
  final String? startTime;

  Medicine(
      {required this.notificationId,
      required this.medicineName,
      required this.dosage,
      required this.interval,
      required this.startTime});

  List<dynamic> get getIds => notificationId!;
  String get getName => medicineName!;
  int get getDosage => dosage!;
  int get getInterval => interval!;
  String get getStartTime => startTime!;

  Map<String, dynamic> toJson() {
    return {
      'ids': notificationId,
      'medicineName': medicineName,
      'dosage': dosage,
      'interval': interval,
      'startTime': startTime
    };
  }

  factory Medicine.fromJson(Map<String, dynamic> parsedJson) {
    return Medicine(
        notificationId: parsedJson['ids'],
        medicineName: parsedJson['medicineName'],
        dosage: parsedJson['dosage'],
        interval: parsedJson['interval'],
        startTime: parsedJson['startTime']);
  }
}
