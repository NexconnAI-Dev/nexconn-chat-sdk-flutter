/// The unified export entry for the Nexconn Flutter IM SDK.
///
/// This library provides:
///
/// - Engine initialization, connection management, and global event registration.
/// - Channel models for direct, group, open, community, and system conversations.
/// - Message types such as text, image, voice, video, file, and combined messages.
/// - Paginated queries for channels, messages, groups, friends, and tags.
/// - Models and enums for users, groups, tags, push, and translation features.
///
/// Quick start:
///
/// ```dart
/// import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
///
/// await NCEngine.initialize(
///   InitParams(appKey: 'YOUR_APP_KEY'),
/// );
///
/// await NCEngine.connect(
///   ConnectParams(token: 'YOUR_USER_TOKEN'),
///   (userId, error) {},
/// );
/// ```
library ai_nexconn_chat_plugin;

export 'src/engine/nc_engine.dart';

export 'src/channel/base_channel.dart';
export 'src/channel/direct_channel.dart';
export 'src/channel/group_channel.dart';
export 'src/channel/open_channel.dart';
export 'src/channel/community_channel.dart';
export 'src/channel/community_sub_channel.dart';
export 'src/channel/system_channel.dart';

export 'src/query/channel_list_query.dart';
export 'src/query/message_query.dart';
export 'src/query/search_query.dart';
export 'src/query/group_query.dart';
export 'src/query/friend_query.dart';
export 'src/query/tag_query.dart';
export 'src/query/open_channel_messages_query.dart';

export 'src/message/message.dart';
export 'src/message/media_message.dart';
export 'src/message/text_message.dart';
export 'src/message/image_message.dart';
export 'src/message/hd_voice_message.dart';
export 'src/message/short_video_message.dart';
export 'src/message/file_message.dart';
export 'src/message/gif_message.dart';
export 'src/message/combine_message.dart';
export 'src/message/custom_media_message.dart';
export 'src/message/location_message.dart';
export 'src/message/reference_message.dart';
export 'src/message/custom_message.dart';
export 'src/message/command_message.dart';
export 'src/message/command_notification_message.dart';
export 'src/message/stream_message.dart';
export 'src/message/group_notification_message.dart';
export 'src/message/unknown_message.dart';
export 'src/message/mentioned_info.dart';
export 'src/message/received_status_info.dart';
export 'src/message/group_read_receipt_info.dart';
export 'src/message/user_info.dart';
export 'src/model/group_info.dart';
export 'src/model/group_member_info.dart';
export 'src/model/group_application_info.dart';
export 'src/model/friend_info.dart';
export 'src/model/friend_relation_info.dart';
export 'src/model/friend_application_info.dart';
export 'src/model/favorite_info.dart';
export 'src/model/user_profile.dart';
export 'src/model/tag.dart';
export 'src/model/channel_tag_info.dart';
export 'src/model/typing_status.dart';
export 'src/model/read_receipt_response_v5.dart';
export 'src/model/read_receipt_info.dart';
export 'src/model/blocked_message_info.dart';
export 'src/model/speech_to_text_info.dart';
export 'src/model/translate_item.dart';
export 'src/model/participant_action.dart';
export 'src/model/participant_ban_event.dart';
export 'src/model/participant_block_event.dart';
export 'src/model/open_channel_sync_event.dart';
export 'src/model/subscribe_status_info.dart';
export 'src/model/subscribe_change_event.dart';
export 'src/model/subscribe_event_request.dart';
export 'src/model/search_channel_result.dart';
export 'src/model/paging_query_option.dart';
export 'src/model/paging_query_result.dart';
export 'src/model/page_data.dart';
export 'src/model/leave_group_config.dart';
export 'src/model/push_config.dart';
export 'src/model/engine_options.dart';
export 'src/model/app_settings.dart';
export 'src/model/translate_params.dart';
export 'src/model/combine_msg_info.dart';

export 'src/enum/channel_type.dart';
export 'src/enum/connection_status.dart';
export 'src/enum/no_disturb_level.dart';
export 'src/enum/no_disturb_time_level.dart';
export 'src/enum/message_operation_policy.dart';
export 'src/enum/translate_strategy.dart';
export 'src/enum/log_level.dart';
export 'src/enum/message_type.dart';
export 'src/enum/message_direction.dart';
export 'src/enum/sent_status.dart';
export 'src/enum/received_status.dart';
export 'src/enum/mentioned_type.dart';
export 'src/enum/custom_message_policy.dart';
export 'src/enum/custom_message_persistent_flag.dart';
export 'src/enum/group_member_role.dart';
export 'src/enum/group_operation.dart';
export 'src/enum/group_operation_type.dart';
export 'src/enum/group_application_direction.dart';
export 'src/enum/group_application_status.dart';
export 'src/enum/group_application_type.dart';
export 'src/enum/group_join_permission.dart';
export 'src/enum/group_operation_permission.dart';
export 'src/enum/group_invite_handle_permission.dart';
export 'src/enum/group_member_info_edit_permission.dart';
export 'src/enum/group_status.dart';
export 'src/enum/friend_application_type.dart';
export 'src/enum/friend_application_status.dart';
export 'src/enum/friend_add_permission.dart';
export 'src/enum/friend_relation_type.dart';
export 'src/enum/subscribe_type.dart';
export 'src/enum/subscribe_operation_type.dart';
export 'src/enum/open_channel_status.dart';
export 'src/enum/metadata_operation_type.dart';
export 'src/enum/open_channel_member_action_info.dart';
export 'src/enum/participant_ban_type.dart';
export 'src/enum/participant_operate_type.dart';
export 'src/enum/open_channel_sync_status.dart';
export 'src/enum/open_channel_sync_status_reason.dart';
export 'src/enum/user_profile_visibility.dart';
export 'src/enum/speech_to_text_status.dart';
export 'src/enum/message_block_type.dart';
export 'src/enum/area_code.dart';
export 'src/enum/user_gender.dart';
export 'src/enum/translate_result_type.dart';
export 'src/enum/translate_status.dart';
export 'src/enum/translate_mode.dart';
export 'src/enum/vivo_push_type.dart';
export 'src/enum/huawei_push_importance.dart';
export 'src/enum/honor_push_importance.dart';

export 'src/error/nc_error.dart';
export 'src/internal/types.dart';
export 'src/internal/converter.dart';
export 'src/internal/handler_registry.dart';

export 'src/handler/connection_handler.dart';
export 'src/handler/message_handler.dart';
export 'src/handler/channel_handler.dart';
export 'src/handler/open_channel_handler.dart';
export 'src/handler/group_channel_handler.dart';
export 'src/handler/user_handler.dart';
export 'src/handler/translate_handler.dart';
