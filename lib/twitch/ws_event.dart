class WsMessage {
  final WsMessagePayload payload;

  WsMessage({required this.payload});

  static WsMessage fromJson(dynamic json) {
    return WsMessage(payload: WsMessagePayload.fromJson(json['payload']));
  }
}

class WsMessagePayload {
  final WsMessageSubscription? subscription;
  final WsMessageEvent? event;

  WsMessagePayload({required this.subscription, required this.event});

  static WsMessagePayload fromJson(dynamic json) {
    final eventJson = json['event'];
    final subsJson = json['subscription'];

    return WsMessagePayload(
      subscription:
          subsJson != null ? WsMessageSubscription.fromJson(subsJson) : null,
      event: eventJson != null ? WsMessageEvent.fromJson(eventJson) : null,
    );
  }
}

class WsReward {
  final String title;
  final int cost;

  WsReward({required this.title, required this.cost});

  static WsReward fromJson(dynamic json) {
    return WsReward(title: json['title'] as String, cost: json['cost'] as int);
  }
}

class WsMessageEvent {
  final String? id;

  final UserInfo? user;

  final WsReward? reward;
  final WsChatMessage? message;

  final UserInfo? chatter;

  /*Example: text, power_ups_gigantified_emote, power_ups_message_effect, channel_points_highlighted*/
  final String? messageType;

  final String? messageId;
  final String? color;

  final WsReply? reply;
  final String? userInput;

  final UserInfo? fromBroadcaster;
  final UserInfo? toBroadcaster;
  final int? viewers;

  final int? total;
  final bool? anonymous;
  final String? tier;
  final bool? gift;
  final int? cumulativeMonths;

  WsMessageEvent({
    required this.id,
    required this.user,
    required this.reward,
    required this.message,
    required this.messageType,
    required this.chatter,
    required this.messageId,
    required this.color,
    required this.reply,
    required this.userInput,
    required this.fromBroadcaster,
    required this.toBroadcaster,
    required this.viewers,
    required this.total,
    required this.anonymous,
    required this.tier,
    required this.gift,
    required this.cumulativeMonths,
  });

  static WsMessageEvent fromJson(dynamic json) {
    final rewardJson = json['reward'];
    final messageJson = json['message'];
    final replyJson = json['reply'];

    return WsMessageEvent(
      id: json['id'] as String?,
      user: ParseUtil.parseUserInfo(json),
      fromBroadcaster: ParseUtil.parseUserInfo(
        json,
        prefix: 'from_broadcaster_',
      ),
      toBroadcaster: ParseUtil.parseUserInfo(json, prefix: 'to_broadcaster_'),
      chatter: ParseUtil.parseUserInfo(json, prefix: 'chatter_'),
      message: messageJson != null ? WsChatMessage.fromJson(messageJson) : null,
      reward: rewardJson != null ? WsReward.fromJson(rewardJson) : null,
      messageType: json['message_type'] as String?,
      messageId: json['message_id'] as String?,
      color: json['color'] as String?,
      reply: replyJson != null ? WsReply.fromJson(replyJson) : null,
      userInput: json['user_input'] as String?,
      viewers: json['viewers'] as int?,
      total: json['total'] as int?,
      anonymous: json['is_anonymous'] as bool?,
      tier: json['tier'] as String?,
      gift: json['is_gift'] as bool?,
      cumulativeMonths: json['cumulative_months'] as int?,
    );
  }
}

class UserInfo {
  final String id;
  final String login;
  final String name;

  UserInfo({required this.id, required this.login, required this.name});
}

class ParseUtil {
  ParseUtil._();

  static UserInfo? parseUserInfo(dynamic json, {String prefix = ''}) {
    final id = json['${prefix}user_id'] as String?;
    final login = json['${prefix}user_login'] as String?;
    final name = json['${prefix}user_name'] as String?;

    if (id != null && login != null && name != null) {
      return UserInfo(id: id, login: login, name: name);
    } else {
      return null;
    }
  }
}

class WsReply {
  final UserInfo? parentUser;
  final String? parentMessageBody;

  WsReply({required this.parentUser, required this.parentMessageBody});

  static WsReply fromJson(dynamic json) {
    return WsReply(
      parentUser: ParseUtil.parseUserInfo(json, prefix: 'parent_'),
      parentMessageBody: json['parent_message_body'] as String?,
    );
  }
}

class WsMessageSubscription {
  static const raid = 'channel.raid';

  final String type;

  WsMessageSubscription({required this.type});

  static WsMessageSubscription fromJson(dynamic json) {
    return WsMessageSubscription(type: json['type'] as String);
  }
}

class WsChatMessage {
  final String? text;
  final List<WsChatMessageFragment> fragments;

  WsChatMessage({required this.text, required this.fragments});

  static WsChatMessage fromJson(dynamic json) {
    return WsChatMessage(
      text: json['text'] as String?,
      fragments:
          ((json['fragments'] as List<dynamic>? ?? []).map(
            WsChatMessageFragment.fromJson,
          )).toList(),
    );
  }
}

enum WsFragmentType {
  mention,
  text,
  emote,
  unknown;

  static WsFragmentType fromString(String type) {
    for (var e in WsFragmentType.values) {
      if (type == e.name) {
        return e;
      }
    }
    return unknown;
  }
}

class WsChatMessageFragment {
  final WsFragmentType type;
  final String? text;
  final WsChatEmote? emote;

  WsChatMessageFragment({
    required this.type,
    required this.text,
    required this.emote,
  });

  static WsChatMessageFragment fromJson(dynamic json) {
    final emoteJson = json['emote'];
    return WsChatMessageFragment(
      type: WsFragmentType.fromString(json['type'] as String),
      text: json['text'] as String?,
      emote: emoteJson != null ? WsChatEmote.fromJson(emoteJson) : null,
    );
  }
}

class WsChatEmote {
  final String id;
  final List<String> format;

  WsChatEmote({required this.id, required this.format});

  static WsChatEmote fromJson(dynamic json) {
    return WsChatEmote(
      id: json['id'] as String,
      format:
          (json['format'] as List<dynamic>).map((e) => e.toString()).toList(),
    );
  }
}
