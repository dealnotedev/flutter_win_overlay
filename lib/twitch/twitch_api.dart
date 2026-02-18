import 'package:dio/dio.dart';
import 'package:flutter_win_overlay/settings.dart';
import 'package:flutter_win_overlay/twitch/twitch_creds_interceptor.dart';

class TwitchApi {
  late final Dio dio;

  TwitchApi({required Settings settings, required String clientSecret}) {
    final interceptor = TwitchCredsInterceptor(
      settings: settings,
      clientSecret: clientSecret,
    );
    dio = Dio(BaseOptions(baseUrl: 'https://api.twitch.tv/helix'));
    dio.interceptors.add(interceptor);
  }

  Future<int> cleanupInactiveEventSubs() async {
    final resp = await dio.get('/eventsub/subscriptions');
    final data = (resp.data['data'] as List).cast<Map<String, dynamic>>();

    int count = 0;

    for (final sub in data) {
      final status = sub['status'];
      final id = sub['id'];

      if (status == 'websocket_disconnected') {
        await dio.delete(
          '/eventsub/subscriptions',
          queryParameters: {'id': id},
        );
        count++;
      }
    }

    return count;
  }

  Future<void> subscribeCustomRewards({
    required String? broadcasterUserId,
    required String sessionId,
  }) {
    final data = {
      'version': '1',
      'type': 'channel.channel_points_custom_reward_redemption.add',
      'condition': {'broadcaster_user_id': broadcasterUserId},
      'transport': {'session_id': sessionId, 'method': 'websocket'},
    };

    return dio.post('/eventsub/subscriptions', data: data);
  }

  Future<UserDto> getUser({required String? id}) {
    return dio
        .get(id != null ? '/users?id=$id' : '/users')
        .then((value) => value.data)
        .then((value) => value['data'] as List<dynamic>)
        .then((value) => value[0])
        .then(UserDto.fromJson);
  }
}

class UserDto {
  final String id;
  final String login;
  final String? displayName;
  final String? profileImageUrl;

  static const dealnotedev = UserDto(
    id: '215541934',
    login: 'dealnotedev',
    displayName: 'DealnoteDev',
    profileImageUrl:
        'https://static-cdn.jtvnw.net/jtv_user_pictures/b49bedc2-8fbb-4485-9a1b-b5cb6e52e864-profile_image-300x300.png',
  );

  const UserDto({
    required this.id,
    required this.login,
    required this.displayName,
    required this.profileImageUrl,
  });

  static UserDto fromJson(dynamic json) {
    return UserDto(
      id: json['id'] as String,
      login: json['login'] as String,
      displayName: json['display_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }
}
