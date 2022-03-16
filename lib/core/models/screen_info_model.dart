class ScreenInfo {
  ScreenInfo({required this.screenToken, required this.batteryPercentage, required this.lowBatteryThreshold, required this.lowBatteryNotificationDelay, required this.updateBatteryDelay});

  ScreenInfo.fromJson(Map<String, Object?> json)
      : this(
          screenToken: json['screenToken']! as String,
          batteryPercentage: json['batteryPercentage']! as int,
          lowBatteryThreshold: json['lowBatteryThreshold']! as int,
          lowBatteryNotificationDelay: json['lowBatteryNotificationDelay']! as int,
          updateBatteryDelay: json['updateBatteryDelay']! as int,
        );

  final String screenToken;
  final int batteryPercentage;
  int lowBatteryThreshold;
  int lowBatteryNotificationDelay;
  int updateBatteryDelay;

  Map<String, Object?> toJson() {
    return {
      'screenToken': screenToken,
      'batteryPercentage': batteryPercentage,
      'lowBatteryThreshold': lowBatteryThreshold,
      'lowBatteryNotificationDelay': lowBatteryNotificationDelay,
      'updateBatteryDelay': updateBatteryDelay,
    };
  }
}
