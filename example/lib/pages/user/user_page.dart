import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_nexconn_chat_plugin/ai_nexconn_chat_plugin.dart';
import '../../widgets/api_widgets.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  FriendApplicationsQuery? _friendApplicationsQuery;
  SubscribeQuery? _subscribeQuery;

  UserGender? _parseGenderInput(String? rawValue, String action) {
    final text = (rawValue ?? '').trim();
    if (text.isEmpty) return null;
    final idx = int.tryParse(text);
    if (idx == null || idx < 0 || idx >= UserGender.values.length) {
      showResult('$action [onError]', {'error': 'Gender only supports 0/1/2'});
      return null;
    }
    return UserGender.values[idx];
  }

  Map<String, dynamic>? _parseJsonMapInput(
    String input,
    String action,
    String fieldName,
  ) {
    final text = input.trim();
    if (text.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
      showResult('$action [onError]', {
        'error': '$fieldName must be a JSON object',
      });
      return null;
    } catch (_) {
      showResult('$action [onError]', {
        'error': '$fieldName is not valid JSON',
      });
      return null;
    }
  }

  SubscribeType? _parseSubscribeTypeInput(String? rawValue, String action) {
    final text = (rawValue ?? '').trim();
    final idx = int.tryParse(text);
    if (idx == null || idx < 0 || idx >= SubscribeType.values.length) {
      showResult('$action [onError]', {
        'error': 'SubscribeType only supports 0-${SubscribeType.values.length - 1}',
      });
      return null;
    }
    return SubscribeType.values[idx];
  }

  List<T>? _parseEnumListInput<T>(
    String? rawValue,
    List<T> values,
    String action,
    String fieldName,
  ) {
    final text = (rawValue ?? '').trim();
    if (text.isEmpty) {
      showResult('$action [onError]', {'error': '$fieldName cannot be empty'});
      return null;
    }
    final indexes = text.split(',').map((s) => int.tryParse(s.trim())).toList();
    if (indexes.any((index) => index == null)) {
      showResult('$action [onError]', {
        'error': '$fieldName only supports comma-separated numeric indexes',
      });
      return null;
    }
    final result = <T>[];
    for (final index in indexes.cast<int>()) {
      if (index < 0 || index >= values.length) {
        showResult('$action [onError]', {
          'error': '$fieldName index out of range: $index',
        });
        return null;
      }
      result.add(values[index]);
    }
    return result;
  }

  List<String> _parseUserIdsInput(String? rawValue) {
    return (rawValue ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _subscribeEvent() async {
    final args = await showParamsDialog(
      context,
      title: 'Subscribe User Status',
      params: [
        (
          label: 'SubscribeType(0-${SubscribeType.values.length - 1})',
          hint: '0',
          isNumber: true,
        ),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
        (label: 'Expiry', hint: '0', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final subscribeType = _parseSubscribeTypeInput(
      args['SubscribeType(0-${SubscribeType.values.length - 1})'],
      'subscribeEvent',
    );
    if (subscribeType == null) return;
    final userIds = _parseUserIdsInput(args['UserIds(comma)']);
    final expiry = int.tryParse(args['Expiry'] ?? '0') ?? 0;
    showInput('subscribeEvent', {
      'subscribeType': subscribeType.name,
      'userIds': userIds,
      'expiry': expiry,
    });
    await NCEngine.user.subscribeEvent(
      SubscribeEventParams(
        subscribeType: subscribeType,
        userIds: userIds,
        expiry: expiry,
      ),
      (failedUserIds, error) {
        showResult(
          'subscribeEvent [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {'failedUserIds': failedUserIds ?? []},
        );
      },
    );
  }

  void _unsubscribeEvent() async {
    final args = await showParamsDialog(
      context,
      title: 'Unsubscribe User Status',
      params: [
        (
          label: 'SubscribeType(0-${SubscribeType.values.length - 1})',
          hint: '0',
          isNumber: true,
        ),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final subscribeType = _parseSubscribeTypeInput(
      args['SubscribeType(0-${SubscribeType.values.length - 1})'],
      'unsubscribeEvent',
    );
    if (subscribeType == null) return;
    final userIds = _parseUserIdsInput(args['UserIds(comma)']);
    showInput('unsubscribeEvent', {
      'subscribeType': subscribeType.name,
      'userIds': userIds,
    });
    await NCEngine.user.unsubscribeEvent(
      UnsubscribeEventParams(
        subscribeType: subscribeType,
        userIds: userIds,
      ),
      (failedUserIds, error) {
        showResult(
          'unsubscribeEvent [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {'failedUserIds': failedUserIds ?? []},
        );
      },
    );
  }

  void _getSubscribeEvent() async {
    final args = await showParamsDialog(
      context,
      title: 'Get Subscription Status',
      params: [
        (
          label: 'SubscribeType(0-${SubscribeType.values.length - 1})',
          hint: '0',
          isNumber: true,
        ),
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final subscribeType = _parseSubscribeTypeInput(
      args['SubscribeType(0-${SubscribeType.values.length - 1})'],
      'getSubscribeEvent',
    );
    if (subscribeType == null) return;
    final userIds = _parseUserIdsInput(args['UserIds(comma)']);
    showInput('getSubscribeEvent', {
      'subscribeType': subscribeType.name,
      'userIds': userIds,
    });
    await NCEngine.user.getSubscribeEvent(
      GetSubscribeEventParams(
        subscribeType: subscribeType,
        userIds: userIds,
      ),
      (statusInfos, error) {
        showResult(
          'getSubscribeEvent [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': statusInfos?.length ?? 0,
                  'statusInfos':
                      statusInfos?.map((e) => e.toJson()).toList() ?? [],
                },
        );
      },
    );
  }

  void _createSubscribeQuery() async {
    final args = await showParamsDialog(
      context,
      title: 'Create Subscription Query',
      params: [
        (
          label: 'SubscribeType(0-${SubscribeType.values.length - 1})',
          hint: '0',
          isNumber: true,
        ),
        (label: 'PageSize', hint: '20', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final subscribeType = _parseSubscribeTypeInput(
      args['SubscribeType(0-${SubscribeType.values.length - 1})'],
      'createSubscribeQuery',
    );
    if (subscribeType == null) return;
    final pageSize = int.tryParse(args['PageSize'] ?? '20') ?? 20;
    _subscribeQuery = NCEngine.user.createSubscribeQuery(
      SubscribeQueryParams(
        subscribeType: subscribeType,
        pageSize: pageSize,
      ),
    );
    showInput('createSubscribeQuery', {
      'subscribeType': subscribeType.name,
      'pageSize': pageSize,
    });
    showResult('createSubscribeQuery', {'result': 'query created'});
  }

  void _createFriendApplicationsQuery() async {
    final args = await showParamsDialog(
      context,
      title: 'Create Friend Applications Query',
      params: [
        (
          label: 'ApplicationTypes(0=sent,1=received; comma separated)',
          hint: '0,1',
          isNumber: false,
        ),
        (
          label:
              'Statuses(0=unhandled,1=accepted,2=refused,3=expired; comma separated)',
          hint: '0,1,2,3',
          isNumber: false,
        ),
        (label: 'PageSize', hint: '20', isNumber: true),
      ],
    );
    if (args == null || !mounted) return;
    final applicationTypes = _parseEnumListInput<FriendApplicationType>(
      args['ApplicationTypes(0=sent,1=received; comma separated)'],
      FriendApplicationType.values,
      'createFriendApplicationsQuery',
      'ApplicationTypes',
    );
    if (applicationTypes == null) return;
    final statuses = _parseEnumListInput<FriendApplicationStatus>(
      args[
          'Statuses(0=unhandled,1=accepted,2=refused,3=expired; comma separated)'],
      FriendApplicationStatus.values,
      'createFriendApplicationsQuery',
      'Statuses',
    );
    if (statuses == null) return;
    final pageSize = int.tryParse(args['PageSize'] ?? '20') ?? 20;
    _friendApplicationsQuery = NCEngine.user.createFriendApplicationsQuery(
      FriendApplicationsQueryParams(
        applicationTypes: applicationTypes,
        applicationStatuses: statuses,
        pageSize: pageSize,
      ),
    );
    showInput('createFriendApplicationsQuery', {
      'applicationTypes': applicationTypes.map((e) => e.name).toList(),
      'statuses': statuses.map((e) => e.name).toList(),
      'pageSize': pageSize,
    });
    showResult('createFriendApplicationsQuery', {'result': 'query created'});
  }

  void _loadFriendApplicationsQueryNextPage() async {
    final query = _friendApplicationsQuery;
    if (query == null) {
      showResult('loadFriendApplicationsQueryNextPage [onError]', {
        'error': 'Create Friend Applications Query first',
      });
      return;
    }
    showInput('loadFriendApplicationsQueryNextPage', const {});
    await query.loadNextPage((page, error) {
      showResult(
        'loadFriendApplicationsQueryNextPage [${hasError(error) ? 'onError' : 'onSuccess'}]',
        hasError(error)
            ? error?.toJson()
            : {
                'count': page?.data.length ?? 0,
                'totalCount': page?.totalCount ?? 0,
                'applications':
                    page?.data.map((e) => e.toJson()).toList() ?? [],
              },
      );
    });
  }

  void _loadSubscribeQueryNextPage() async {
    final query = _subscribeQuery;
    if (query == null) {
      showResult('loadSubscribeQueryNextPage [onError]', {
        'error': 'Create Subscription Query first',
      });
      return;
    }
    showInput('loadSubscribeQueryNextPage', const {});
    await query.loadNextPage((page, error) {
      showResult(
        'loadSubscribeQueryNextPage [${hasError(error) ? 'onError' : 'onSuccess'}]',
        hasError(error)
            ? error?.toJson()
            : {
                'count': page?.data.length ?? 0,
                'statusInfos': page?.data.map((e) => e.toJson()).toList() ?? [],
              },
      );
    });
  }

  void _updateMyUserProfile() async {
    final portraitPath = await pickLocalFile(FilePickType.image);
    if (!mounted) return;
    final args = await showParamsDialog(
      context,
      title: 'Update My User Profile',
      params: [
        (label: 'Name', hint: 'nickname', isNumber: false),
        (label: 'Gender(0=unknown,1=male,2=female)', hint: '0', isNumber: true),
        (label: 'Email', hint: 'user@example.com', isNumber: false),
        (label: 'Birthday', hint: '1990-01-01', isNumber: false),
        (label: 'Location', hint: 'Shanghai', isNumber: false),
        (label: 'Extra', hint: '{}', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final gender = _parseGenderInput(
      args['Gender(0=unknown,1=male,2=female)'],
      'updateMyUserProfile',
    );
    if ((args['Gender(0=unknown,1=male,2=female)'] ?? '').trim().isNotEmpty &&
        gender == null) {
      return;
    }
    final extProfile = _parseJsonMapInput(
      args['Extra'] ?? '',
      'updateMyUserProfile',
      'Extra',
    );
    if (extProfile == null || !mounted) return;
    final profile = UserProfile(
      name: args['Name'] ?? '',
      avatarUrl: portraitPath,
      email: (args['Email'] ?? '').trim(),
      birthday: (args['Birthday'] ?? '').trim(),
      gender: gender,
      location: (args['Location'] ?? '').trim(),
      extProfile: extProfile,
    );
    showInput('updateMyUserProfile', {
      'name': args['Name'] ?? '',
      'avatarUrl': portraitPath,
      'email': (args['Email'] ?? '').trim(),
      'birthday': (args['Birthday'] ?? '').trim(),
      'gender': gender?.name,
      'location': (args['Location'] ?? '').trim(),
      'extProfile': extProfile,
    });
    await NCEngine.user.updateMyUserProfile(profile, (error) {
      showResult(
        'updateMyUserProfile [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _getMyUserProfile() async {
    showInput('getMyUserProfile', const {});
    final code = await NCEngine.user.getMyUserProfile((profile, error) {
      showResult(
          'getMyUserProfile [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error) ? error?.toJson() : profile?.toJson());
    });
    if (code != 0 && mounted) {
      showResult('getMyUserProfile', {'code': code});
    }
  }

  void _getUserProfiles() async {
    final args = await showParamsDialog(
      context,
      title: 'Get User Profiles',
      params: [(label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false)],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('getUserProfiles', {'userIds': userIds});
    await NCEngine.user.getUserProfiles(userIds, (profiles, error) {
      showResult(
          'getUserProfiles [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': profiles?.length,
                  'profiles': profiles?.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _addToBlocklist() async {
    final args = await showParamsDialog(
      context,
      title: 'Add to Blocklist',
      params: [(label: 'UserId', hint: 'userId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('addToBlocklist', {'userId': args['UserId'] ?? ''});
    await NCEngine.user.addToBlocklist(args['UserId'] ?? '', (error) {
      showResult(
        'addToBlocklist [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _removeFromBlocklist() async {
    final args = await showParamsDialog(
      context,
      title: 'Remove from Blocklist',
      params: [(label: 'UserId', hint: 'userId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('removeFromBlocklist', {'userId': args['UserId'] ?? ''});
    await NCEngine.user.removeFromBlocklist(args['UserId'] ?? '', (error) {
      showResult(
        'removeFromBlocklist [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _getBlocklist() async {
    showInput('getBlocklist', const {});
    await NCEngine.user.getBlocklist((userIds, error) {
      showResult('getBlocklist [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error) ? error?.toJson() : {'userIds': userIds});
    });
  }

  void _checkBlocked() async {
    final args = await showParamsDialog(
      context,
      title: 'Check Blocklist Status',
      params: [(label: 'UserId', hint: 'userId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('checkBlocked', {'userId': args['UserId'] ?? ''});
    await NCEngine.user.checkBlocked(args['UserId'] ?? '', (blocked, error) {
      showResult('checkBlocked [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error) ? error?.toJson() : {'blocked': blocked});
    });
  }

  void _addFriend() async {
    final args = await showParamsDialog(
      context,
      title: 'Add Friend',
      params: [
        (label: 'UserId', hint: 'userId', isNumber: false),
        (label: 'Extra', hint: '(optional)', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    showInput('addFriend', {
      'userId': args['UserId'] ?? '',
      'extra': args['Extra'] ?? '',
    });
    final code = await NCEngine.user.addFriend(
      AddFriendParams(
        userId: args['UserId'] ?? '',
        extra: args['Extra'] ?? '',
      ),
      (processCode, error) {
        showResult('addFriend [${hasError(error) ? 'onError' : 'onSuccess'}]',
            hasError(error) ? error?.toJson() : {'processCode': processCode});
      },
    );
    if (code != 0 && mounted) {
      showResult('addFriend', {'code': code});
    }
  }

  void _removeFriends() async {
    final args = await showParamsDialog(
      context,
      title: 'Remove Friend',
      params: [
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('removeFriends', {'userIds': userIds});
    await NCEngine.user.removeFriends(
      userIds,
      (error) => showResult(
        'removeFriends [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      ),
    );
  }

  void _acceptFriendApplication() async {
    final args = await showParamsDialog(
      context,
      title: 'Accept Friend Application',
      params: [(label: 'UserId', hint: 'userId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('acceptFriendApplication', {'userId': args['UserId'] ?? ''});
    await NCEngine.user.acceptFriendApplication(args['UserId'] ?? '', (error) {
      showResult(
        'acceptFriendApplication [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _refuseFriendApplication() async {
    final args = await showParamsDialog(
      context,
      title: 'Refuse Friend Application',
      params: [(label: 'UserId', hint: 'userId', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('refuseFriendApplication', {'userId': args['UserId'] ?? ''});
    await NCEngine.user.refuseFriendApplication(args['UserId'] ?? '', (error) {
      showResult(
        'refuseFriendApplication [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _getFriendsInfo() async {
    final args = await showParamsDialog(
      context,
      title: 'Get Friends Info',
      params: [(label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false)],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('getFriendsInfo', {'userIds': userIds});
    await NCEngine.user.getFriendsInfo(userIds, (infos, error) {
      showResult(
          'getFriendsInfo [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': infos?.length,
                  'friends': infos?.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _setFriendInfo() async {
    final args = await showParamsDialog(
      context,
      title: 'Set Friend Info',
      params: [
        (label: 'UserId', hint: 'userId', isNumber: false),
        (label: 'ExtFields', hint: '{"k":"v"}', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final extFields = _parseJsonMapInput(
      args['ExtFields'] ?? '',
      'setFriendInfo',
      'ExtFields',
    );
    if (extFields == null) return;
    final userId = (args['UserId'] ?? '').trim();
    final extProfile = extFields.isNotEmpty
        ? extFields.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
        : null;
    final params = SetFriendInfoParams(
      userId: userId,
      extProfile: extProfile,
    );
    showInput('setFriendInfo', {
      'userId': userId,
      'extProfile': extProfile,
    });
    await NCEngine.user.setFriendInfo(params, (error) {
      showResult(
        'setFriendInfo [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      );
    });
  }

  void _searchFriendsInfo() async {
    final args = await showParamsDialog(
      context,
      title: 'Search Friends',
      params: [(label: 'Keyword', hint: 'name keyword', isNumber: false)],
    );
    if (args == null || !mounted) return;
    showInput('searchFriendsInfo', {'keyword': args['Keyword'] ?? ''});
    await NCEngine.user.searchFriendsInfo(args['Keyword'] ?? '',
        (infos, error) {
      showResult(
          'searchFriendsInfo [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': infos?.length,
                  'friends': infos?.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _checkFriends() async {
    final args = await showParamsDialog(
      context,
      title: 'Check Friend Relation',
      params: [
        (label: 'UserIds(comma)', hint: 'uid1,uid2', isNumber: false),
      ],
    );
    if (args == null || !mounted) return;
    final userIds = (args['UserIds(comma)'] ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    showInput('checkFriends', {'userIds': userIds});
    await NCEngine.user.checkFriends(
      userIds,
      (infos, error) {
        showResult(
            'checkFriends [${hasError(error) ? 'onError' : 'onSuccess'}]',
            hasError(error)
                ? error?.toJson()
                : {
                    'count': infos?.length,
                    'relations': infos?.map((e) => e.toJson()).toList(),
                  });
      },
    );
  }

  void _friendsQuery() async {
    showInput('getFriends', const {});
    await NCEngine.user.getFriends((friends, error) {
      showResult(
          'getFriends [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error)
              ? error?.toJson()
              : {
                  'count': friends?.length,
                  'friends': friends?.map((e) => e.toJson()).toList(),
                });
    });
  }

  void _getFriendAddPermission() async {
    showInput('getFriendAddPermission', const {});
    await NCEngine.user.getFriendAddPermission((type, error) {
      showResult(
          'getFriendAddPermission [${hasError(error) ? 'onError' : 'onSuccess'}]',
          hasError(error) ? error?.toJson() : {'type': type?.name});
    });
  }

  void _setFriendAddPermission() async {
    final args = await showParamsDialog(
      context,
      title: 'Set Friend Add Permission',
      params: [
        (
          label: 'AllowType(1=free,2=needVerify,3=noOneAllowed; 0=notSet cannot be set)',
          hint: '1',
          isNumber: true
        )
      ],
    );
    if (args == null || !mounted) return;
    final idx = int.tryParse(args[
                'AllowType(1=free,2=needVerify,3=noOneAllowed; 0=notSet cannot be set)'] ??
            '1') ??
        1;
    if (idx <= 0 || idx >= FriendAddPermission.values.length) {
      showResult('setFriendAddPermission', {
        'error': 'AllowType must be 1/2/3 (0=notSet cannot be set)',
        'input': idx,
      });
      return;
    }
    showInput('setFriendAddPermission', {
      'permission': FriendAddPermission.values[idx].name,
    });
    await NCEngine.user.setFriendAddPermission(
      FriendAddPermission.values[idx],
      (error) => showResult(
        'setFriendAddPermission [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      ),
    );
  }

  void _getMyUserProfileVisibility() async {
    showInput('getMyUserProfileVisibility', const {});
    await NCEngine.user.getMyUserProfileVisibility((visibility, error) {
      showResult(
        'getMyUserProfileVisibility [${hasError(error) ? 'onError' : 'onSuccess'}]',
        hasError(error) ? error?.toJson() : {'visibility': visibility},
      );
    });
  }

  void _setMyUserProfileVisibility() async {
    final args = await showParamsDialog(
      context,
      title: 'Set User Profile Visibility',
      params: [(label: 'Visibility(0-N)', hint: '0', isNumber: true)],
    );
    if (args == null || !mounted) return;
    final idx = int.tryParse(args['Visibility(0-N)'] ?? '0') ?? 0;
    if (idx < 0 || idx >= UserProfileVisibility.values.length) {
      showResult('setMyUserProfileVisibility', {
        'error': 'Visibility must be 0-${UserProfileVisibility.values.length - 1}',
        'input': idx,
      });
      return;
    }
    showInput('setMyUserProfileVisibility', {
      'visibility': UserProfileVisibility.values[idx].name,
    });
    await NCEngine.user.updateMyUserProfileVisibility(
      UserProfileVisibility.values[idx],
      (error) => showResult(
        'setMyUserProfileVisibility [${isSuccessResult(error) ? 'onSuccess' : 'onError'}]',
        error?.toJson(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User/Friend')),
      body: ListView(
        children: [
          ApiSection(
            title: 'User Profile',
            children: [
              ApiButton(label: 'Update My User Profile', onPressed: _updateMyUserProfile),
              ApiButton(label: 'Get My User Profile', onPressed: _getMyUserProfile),
              ApiButton(label: 'Get User Profiles', onPressed: _getUserProfiles),
              ApiButton(
                  label: 'Get User Profile Visibility', onPressed: _getMyUserProfileVisibility),
              ApiButton(
                  label: 'Set User Profile Visibility', onPressed: _setMyUserProfileVisibility),
            ],
          ),
          ApiSection(
            title: 'Blocklist',
            children: [
              ApiButton(label: 'Add to Blocklist', onPressed: _addToBlocklist),
              ApiButton(label: 'Remove from Blocklist', onPressed: _removeFromBlocklist),
              ApiButton(label: 'Get Blocklist', onPressed: _getBlocklist),
              ApiButton(label: 'Check Blocklist Status', onPressed: _checkBlocked),
            ],
          ),
          ApiSection(
            title: 'Friend Management',
            children: [
              ApiButton(label: 'Add Friend', onPressed: _addFriend),
              ApiButton(label: 'Remove Friend', onPressed: _removeFriends),
              ApiButton(label: 'Accept Friend Application', onPressed: _acceptFriendApplication),
              ApiButton(label: 'Refuse Friend Application', onPressed: _refuseFriendApplication),
              ApiButton(label: 'Get Friends Info', onPressed: _getFriendsInfo),
              ApiButton(label: 'Set Friend Info', onPressed: _setFriendInfo),
              ApiButton(label: 'Search Friends', onPressed: _searchFriendsInfo),
              ApiButton(label: 'Check Friend Relation', onPressed: _checkFriends),
              ApiButton(
                label: 'Create Friend Applications Query',
                onPressed: _createFriendApplicationsQuery,
              ),
              ApiButton(
                label: 'Load Next Friend Applications Page',
                onPressed: _loadFriendApplicationsQueryNextPage,
              ),
              ApiButton(label: 'Friends Query', onPressed: _friendsQuery),
              ApiButton(label: 'Get Friend Add Permission', onPressed: _getFriendAddPermission),
              ApiButton(label: 'Set Friend Add Permission', onPressed: _setFriendAddPermission),
            ],
          ),
          ApiSection(
            title: 'Subscription',
            children: [
              ApiButton(label: 'Subscribe User Status', onPressed: _subscribeEvent),
              ApiButton(label: 'Unsubscribe User Status', onPressed: _unsubscribeEvent),
              ApiButton(label: 'Get Subscription Status', onPressed: _getSubscribeEvent),
              ApiButton(label: 'Create Subscription Query', onPressed: _createSubscribeQuery),
              ApiButton(
                  label: 'Load Next Subscription Page', onPressed: _loadSubscribeQueryNextPage),
            ],
          ),
        ],
      ),
    );
  }
}
