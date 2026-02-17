import 'package:flutter/material.dart';
import 'package:flutter_win_overlay/secrets.dart';
import 'package:flutter_win_overlay/settings.dart';
import 'package:flutter_win_overlay/twitch/twitch_authenticator.dart';

class TwitchLoginWidget extends StatefulWidget {
  final Settings settings;

  const TwitchLoginWidget({super.key, required this.settings});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<TwitchLoginWidget> {
  final _authenticator = TwitchAuthenticator(
    clientId: twitchClientId,
    clientSecret: twitchClientSecret,
    oauthRedirectUrl: twitchOauthRedirectUrl,
  );

  @override
  void initState() {
    _login2Twitch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Please, Login to Twitch via browser',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _login2Twitch() async {
    final creds = await _authenticator.login();
    await widget.settings.saveTwitchAuth(creds);
  }
}
