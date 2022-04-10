import 'package:cloud_firestore/cloud_firestore.dart';

/// A screen's basic information.
class Screen {
  Screen({
    required this.pairingCode,
    required this.paired,
    required this.name,
    required this.userID,
    required this.lastUpdated,
    required this.screenToken,
    required this.width,
    required this.height,
  });

  /// Named constructor to create [Screen] from a Map.
  Screen.fromJson(Map<String, Object?> json)
      : this(
          pairingCode: json['pairingCode']! as String,
          paired: json['paired']! as bool,
          name: json['name']! as String,
          userID: json['userID']! as String,
          lastUpdated: DateTime.parse(
              (json['lastUpdated']! as Timestamp).toDate().toString()),
          screenToken: json['screenToken']! as String,
          width: (json['width']! as num).toDouble(),
          height: (json['height']! as num).toDouble(),
        );

  /// The pairing code used to pair this screen.
  /// 
  /// The [pairingCode] is set to an empty string after successful pairing.
  final String pairingCode;

  /// The pairing status of this screen
  /// 
  /// True if the [Screen] is paired, otherwise false.
  final bool paired;

  /// The name of this screen
  final String name;

  /// The id of the user has paired this screen
  final String userID;

  /// The last [DateTime] at which some information of this screen was updated
  /// 
  /// For example, when a new message was inserted.
  final DateTime lastUpdated;

  /// The unique identifier for this screen.
  final String screenToken;

  /// The logical pixel width of this screen.
  final double width;

  /// The logical pixel height of this screen.
  final double height;

  /// The current instance as a [Map].
  Map<String, Object?> toJson() {
    return {
      'pairingCode': pairingCode,
      'paired': paired,
      'name': name,
      'userID': userID,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'screenToken': screenToken,
      'width': width,
      'height': height,
    };
  }
}
