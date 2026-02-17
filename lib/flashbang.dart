import 'package:flutter/material.dart';
import 'package:flutter_win_overlay/animated_mover.dart';
import 'package:flutter_win_overlay/audio_player.dart';
import 'package:flutter_win_overlay/generated/assets.dart';

class FlashbangWidget extends StatefulWidget {
  final Flashbang flashbang;
  final BoxConstraints constraints;

  const FlashbangWidget({
    super.key,
    required this.constraints,
    required this.flashbang,
  });

  @override
  State<StatefulWidget> createState() => _State();
}

class Flashbang {
  final String id;

  Flashbang({required this.id});
}

class _State extends State<FlashbangWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turns;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _turns = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _startAnimation();
  }


  Future<void> _startAnimation() async {
    _controller.repeat();

    if (!await _sleep(350)) return;

    AudioPlayer.playWavAssetsDebug(Assets.assetsWavFlashbang);

    if (!await _sleep(400)) return;

    _animateToAngle(270);

    if (!await _sleep(250)) return;

    setState(() {
      _flashed = true;
      _alpha = 1.0;
    });

    if (!await _sleep(2000)) return;

    setState(() {
      _alpha = 0.0;
    });
  }

  Future<bool> _sleep(int millis) async {
    await Future.delayed(Duration(milliseconds: millis));
    return mounted;
  }

  Future<void> _animateToAngle(
    double degrees, {
    Curve curve = Curves.easeOut,
  }) async {
    final target = (degrees % 360) / 360.0;

    final current = _controller.value % 1.0;

    double delta = target - current;
    if (delta < 0) delta += 1.0;

    const epsilon = 1e-4;

    if (delta < epsilon) {
      _controller
        ..stop()
        ..value = target;
      return;
    }

    final full = _controller.duration ?? const Duration(milliseconds: 500);

    final adaptive = Duration(
      milliseconds: (full.inMilliseconds * delta).round().clamp(
        1,
        full.inMilliseconds,
      ),
    );

    await _controller.animateTo(
      _controller.value + delta,
      duration: adaptive,
      curve: curve,
    );

    _controller.value = target;
  }

  bool _flashed = false;
  double _alpha = 1.0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flashed) {
      return AnimatedOpacity(
        opacity: _alpha,
        duration: Duration(milliseconds: 1000),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
      );
    }
    return AnimatedVerticalMover(
      toOffset: -100,
      curve: Curves.bounceOut,
      duration: Duration(milliseconds: 750),
      size: Size(128, 128),
      constraints: widget.constraints,
      alreadyInsideStack: true,
      child: RotationTransition(
        turns: _turns,
        child: Image.asset(
          Assets.assetsFlashBomb,
          width: 128,
          height: 128,
        ),
      ),
    );
  }
}
