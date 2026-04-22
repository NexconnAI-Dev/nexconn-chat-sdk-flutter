import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import '../enum/user_gender.dart';

/// User profile information.
///
/// Includes fields such as display name, avatar, email, birthday, location,
/// and custom extended profile data.
class UserProfile {
  final RCIMIWUserProfile _raw;
  UserProfile._(this._raw);

  /// Creates a [UserProfile] from an existing SDK object.
  static UserProfile fromRaw(RCIMIWUserProfile raw) => UserProfile._(raw);

  /// Creates a [UserProfile] from the provided fields.
  UserProfile({
    String? name,
    String? avatarUrl,
    String? email,
    String? birthday,
    UserGender? gender,
    String? location,
    int? role,
    int? level,
    Map? extProfile,
  }) : _raw = RCIMIWUserProfile.create(
         name: name,
         portraitUri: avatarUrl,
         email: email,
         birthday: birthday,
         gender: RCIMIWUserGender.values[(gender ?? UserGender.unknown).index],
         location: location,
         role: role ?? 0,
         level: level ?? 0,
         userExtProfile: extProfile,
       ) {
    _raw.gender ??= RCIMIWUserGender.values[UserGender.unknown.index];
    _raw.role ??= 0;
    _raw.level ??= 0;
  }

  /// The user ID.
  String? get userId => _raw.userId;

  /// The display name.
  String? get name => _raw.name;

  /// The avatar URL.
  String? get avatarUrl => _raw.portraitUri;

  /// An additional unique identifier for the user.
  String? get uniqueId => _raw.uniqueId;

  /// The email address.
  String? get email => _raw.email;

  /// The birthday string. Its format depends on server configuration.
  String? get birthday => _raw.birthday;

  /// The user's gender.
  UserGender? get gender =>
      _raw.gender != null ? UserGender.values[_raw.gender!.index] : null;

  /// The user's location.
  String? get location => _raw.location;

  /// An application-defined role value.
  int? get role => _raw.role;

  /// An application-defined level value.
  int? get level => _raw.level;

  /// Custom extended profile data.
  Map? get extProfile => _raw.userExtProfile;

  /// Converts this object to a JSON-style map.
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'avatarUrl': avatarUrl,
    'uniqueId': uniqueId,
    'email': email,
    'birthday': birthday,
    'gender': gender?.index,
    'location': location,
    'role': role,
    'level': level,
    'extProfile': extProfile,
  };

  /// The associated SDK object for advanced usage.
  RCIMIWUserProfile get raw => _raw;
}
