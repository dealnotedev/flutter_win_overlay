import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_win_overlay/di/service_locator.dart';
import 'package:flutter_win_overlay/events.dart';
import 'package:flutter_win_overlay/flashbang.dart';
import 'package:flutter_win_overlay/secrets.dart';
import 'package:flutter_win_overlay/settings.dart';
import 'package:flutter_win_overlay/twitch/twitch_api.dart';
import 'package:flutter_win_overlay/twitch/twitch_creds.dart';
import 'package:flutter_win_overlay/twitch/ws_event.dart';
import 'package:flutter_win_overlay/twitch/ws_manager.dart';

class LoggedWidget extends StatefulWidget {
  final ServiceLocator locator;
  final TwitchCreds creds;

  const LoggedWidget({super.key, required this.locator, required this.creds});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<LoggedWidget> {
  StreamSubscription<WsMessage>? _eventsSubscription;
  StreamSubscription<WsStateEvent>? _stateSubscription;

  late WsState _state;
  late Settings _settings;

  static const _flashbangDefaultReward = 'Flashbang';
  static const _flashbangDefaultColor = Colors.white;

  Future<void> _overrideWithConfig() async {
    final settings = File('config.json');

    try {
      final config = json.decode(await settings.readAsString());
      final customFlashbangReward = config['flashbang'] as String?;
      final customFlashbangColor = config['flashbang_color'] as String?;

      if (customFlashbangReward != null) {
        _flashbangRewardName = customFlashbangReward;
      }
      if (customFlashbangColor != null) {
        _flashbangColor = _hexToColor(customFlashbangColor);
      }
    } catch (_) {}
  }

  String _flashbangRewardName = _flashbangDefaultReward;
  Color _flashbangColor = _flashbangDefaultColor;

  @override
  void initState() {
    _settings = widget.locator.provide();

    final ws = widget.locator.provide<WebSocketManager>();
    _state = ws.currentState;

    _eventsSubscription = ws.messages.listen(_handleWebsocketMessage);
    _stateSubscription = ws.state.listen(_handleWebsocketState);

    _overrideWithConfig();
    super.initState();
  }

  void _handleWebsocketState(WsStateEvent event) {
    setState(() {
      _state = event.current;
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.dispose();
  }

  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Flashbang? _flashbang;

  @override
  Widget build(BuildContext context) {
    final flashbang = _flashbang;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            _createConnectionIndicator(),

            if (flashbang != null) ...[
              FlashbangWidget(
                constraints: constraints,
                flashbang: flashbang,
                color: _flashbangColor,
                key: ValueKey(flashbang.id),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _createConnectionIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _state == WsState.connected
              ? Color(0xFF51FD0B)
              : Color(0xFFCD0017),
        ),
      ),
    );
  }

  final _receivedEventIds = <String>{};

  Future<void> _handleFlashbang(UserRedeemedEvent reward) async {
    final flashbang = Flashbang(id: reward.id);

    setState(() {
      _flashbang = flashbang;
    });

    await Future.delayed(Duration(seconds: 5));

    if (_flashbang != flashbang) return;

    setState(() {
      _flashbang = null;
    });
  }

  Future<void> _handleReward(UserRedeemedEvent reward) async {
    if (reward.reward == _flashbangRewardName) {
      _handleFlashbang(reward);
      return;
    }
  }

  void _handleWebsocketMessage(WsMessage message) async {
    final event = message.payload.event;

    final eventId = event?.id;
    if (eventId != null && !_receivedEventIds.add(eventId)) {
      // Remove duplicates
      return;
    }

    final userId = event?.user?.id;
    final userName = event?.user?.name;

    final reward = event?.reward?.title;
    final cost = event?.reward?.cost;

    if (eventId != null &&
        userId != null &&
        userName != null &&
        reward != null) {
      final user = await _getUser(userId);

      final event = UserRedeemedEvent(
        eventId,
        time: DateTime.now(),
        user: userName,
        reward: reward,
        avatar: user?.profileImageUrl,
        cost: cost ?? 0,
        input: message.payload.event?.userInput,
      );

      _handleReward(event);
    }
  }

  Future<UserDto?> _getUser(String? userId) async {
    if (userId != null) {
      final UserDto? cached = _users[userId];
      if (cached != null) {
        return cached;
      }
      final api = TwitchApi(
        settings: _settings,
        clientSecret: twitchClientSecret,
      );
      final user = await api.getUser(id: userId);
      _users[userId] = user;
      return user;
    } else {
      return null;
    }
  }

  final _users = <String, UserDto>{};
}
