import 'dart:async';
import 'dart:convert';

import 'package:flutter_win_overlay/twitch/twitch_creds.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static const _kTwitchAuth = 'twitch_credentials';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _initTwitchCreds(prefs);
  }

  Future<void> saveTwitchAuth(TwitchCreds? creds) async {
    final prefs = await SharedPreferences.getInstance();

    if (creds != null) {
      prefs.setString(_kTwitchAuth, jsonEncode(creds.toJson()));
    } else {
      prefs.remove(_kTwitchAuth);
    }

    twitchAuth = creds;
    _twitchAuthSubject.add(creds);
  }

  Stream<TwitchCreds?> get twitchAuthStream =>
      Stream.value(twitchAuth).concatWith([_twitchAuthSubject.stream]);

  Stream<TwitchCreds?> get twitchAuthChanges => _twitchAuthSubject.stream;

  TwitchCreds? twitchAuth;

  final _twitchAuthSubject = StreamController<TwitchCreds?>.broadcast();

  void _initTwitchCreds(SharedPreferences prefs) {
    final json = prefs.getString(_kTwitchAuth);
    twitchAuth = json != null ? TwitchCreds.fromJson(jsonDecode(json)) : null;
  }
}