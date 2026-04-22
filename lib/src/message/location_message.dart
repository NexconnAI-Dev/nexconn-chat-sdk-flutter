import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';
import 'message.dart';

/// Parameters for creating a [LocationMessage].
class LocationMessageParams extends MessageParams {
  /// The longitude coordinate of the location.
  final double longitude;

  /// The latitude coordinate of the location.
  final double latitude;

  /// The display name of the point of interest (POI).
  final String poiName;

  /// The local file path of the location thumbnail image.
  final String thumbnailPath;

  /// Creates [LocationMessageParams] with the required coordinates, POI name, and thumbnail path.
  LocationMessageParams({
    required this.longitude,
    required this.latitude,
    required this.poiName,
    required this.thumbnailPath,
    super.mentionedInfo,
    super.needReceipt,
  });
}

/// A location sharing message in the Nexconn IM SDK.
///
/// Extends [Message] with geographic coordinates, a POI name, and a thumbnail image for displaying the location preview.
class LocationMessage extends Message {
  /// Creates a [LocationMessage] by wrapping a raw message object.
  LocationMessage.wrap(super.raw) : super.wrap();

  /// Creates a [LocationMessage] from an existing SDK object.
  static LocationMessage fromRaw(RCIMIWLocationMessage raw) =>
      LocationMessage.wrap(raw);

  RCIMIWLocationMessage get _locationRaw => raw as RCIMIWLocationMessage;

  /// The longitude coordinate of the shared location.
  double? get longitude => _locationRaw.longitude;

  /// Sets the longitude coordinate.
  set longitude(double? v) => _locationRaw.longitude = v;

  /// The latitude coordinate of the shared location.
  double? get latitude => _locationRaw.latitude;

  /// Sets the latitude coordinate.
  set latitude(double? v) => _locationRaw.latitude = v;

  /// The display name of the point of interest (POI).
  String? get poiName => _locationRaw.poiName;

  /// Sets the POI display name.
  set poiName(String? v) => _locationRaw.poiName = v;

  /// The local file path of the location thumbnail image.
  String? get thumbnailPath => _locationRaw.thumbnailPath;

  /// Sets the thumbnail image path.
  set thumbnailPath(String? v) => _locationRaw.thumbnailPath = v;

  @override
  Map<String, dynamic> extraJson() => {
    'longitude': longitude,
    'latitude': latitude,
    'poiName': poiName,
    'thumbnailPath': thumbnailPath,
  };
}
