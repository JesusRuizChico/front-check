import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _blue = Color(0xFF2D527C);

/// Real UIKit controls on iOS, animated Flutter controls elsewhere.
class WelcomeActionButton extends StatefulWidget {
  const WelcomeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.height,
    this.primary = false,
    this.scale = 1,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final bool primary;
  final double scale;

  @override
  State<WelcomeActionButton> createState() => _WelcomeActionButtonState();
}

class _WelcomeActionButtonState extends State<WelcomeActionButton> {
  final _states = WidgetStatesController();
  MethodChannel? _nativeChannel;
  Map<String, Object>? _lastNativeParameters;

  bool get _nativeIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  Map<String, Object> get _nativeParameters => {
        'label': widget.label,
        'primary': widget.primary,
        'fontSize': (widget.primary ? 25 : 22) * widget.scale,
        'textScale': MediaQuery.textScalerOf(context).scale(1),
        'reduceMotion': _reduceMotion,
      };

  @override
  void initState() {
    super.initState();
    _states.addListener(_interactionChanged);
  }

  void _interactionChanged() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNativeButton();
  }

  @override
  void didUpdateWidget(covariant WelcomeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateNativeButton();
  }

  void _updateNativeButton() {
    if (_nativeChannel == null) return;
    final parameters = _nativeParameters;
    if (mapEquals(parameters, _lastNativeParameters)) return;
    _lastNativeParameters = parameters;
    unawaited(_nativeChannel!.invokeMethod<void>('configure', parameters));
  }

  void _onNativeViewCreated(int id) {
    if (!mounted) return;
    _nativeChannel?.setMethodCallHandler(null);
    _nativeChannel = MethodChannel('habitacheck/welcome_button/$id');
    _nativeChannel!.setMethodCallHandler((call) async {
      if (call.method == 'tap' && mounted) widget.onPressed();
    });
    _lastNativeParameters = null;
    _updateNativeButton();
  }

  @override
  void dispose() {
    _nativeChannel?.setMethodCallHandler(null);
    _states.removeListener(_interactionChanged);
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = _nativeIOS
        ? SizedBox(
            height: widget.height,
            child: UiKitView(
              viewType: 'habitacheck/welcome_button',
              layoutDirection: Directionality.of(context),
              creationParams: _nativeParameters,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onNativeViewCreated,
            ),
          )
        : _flutterButton();

    // A single entrance, no repeating motion; honor Reduce Motion everywhere.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _reduceMotion ? 1 : 0, end: 1),
      duration: _reduceMotion
          ? Duration.zero
          : Duration(milliseconds: widget.primary ? 380 : 500),
      curve: Curves.easeOutCubic,
      child: button,
      builder: (context, progress, child) => Opacity(
        opacity: _reduceMotion ? 1 : progress,
        child: Transform.translate(
          offset: Offset(0, _reduceMotion ? 0 : 10 * (1 - progress)),
          child: child,
        ),
      ),
    );
  }

  Widget _flutterButton() {
    final pressed = _states.value.contains(WidgetState.pressed);
    final active = _states.value.contains(WidgetState.hovered) ||
        _states.value.contains(WidgetState.focused);
    final duration = _reduceMotion
        ? Duration.zero
        : Duration(milliseconds: pressed ? 100 : 240);
    final textStyle =
        (Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(
      fontSize: (widget.primary ? 25 : 22) * widget.scale,
      fontWeight: widget.primary ? FontWeight.w500 : FontWeight.w400,
      letterSpacing: -.3,
    );

    final Widget button;
    if (widget.primary) {
      button = AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: LinearGradient(
            colors: active
                ? [const Color(0xFF416C98), const Color(0xFF2B507C)]
                : [const Color(0xFF355C85), const Color(0xFF24466D)],
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withValues(alpha: active ? .25 : .17),
              blurRadius: active ? 26 : 22,
              offset: Offset(0, pressed ? 4 : 10),
            ),
          ],
        ),
        child: ElevatedButton(
          statesController: _states,
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(0, widget.height),
            padding: EdgeInsets.symmetric(
                horizontal: 15 * widget.scale, vertical: 12),
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: textStyle,
          ),
          child: Row(
            children: [
              SizedBox(width: 30 * widget.scale),
              Expanded(child: Text(widget.label, textAlign: TextAlign.center)),
              Container(
                width: 48 * widget.scale,
                height: 48 * widget.scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF456C99),
                ),
                child: AnimatedSlide(
                  offset: _reduceMotion || !(active || pressed)
                      ? Offset.zero
                      : const Offset(.09, 0),
                  duration: duration,
                  curve: Curves.easeOutCubic,
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 30 * widget.scale),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      button = OutlinedButton(
        statesController: _states,
        onPressed: widget.onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, widget.height),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          foregroundColor: _blue,
          backgroundColor:
              active ? const Color(0xFFE6EDF4) : const Color(0xB3F7F5F1),
          side: BorderSide(color: _blue, width: active ? 1.7 : 1.2),
          shape: const StadiumBorder(),
          textStyle: textStyle,
        ),
        child: Text(widget.label, textAlign: TextAlign.center),
      );
    }

    return AnimatedScale(
      scale: _reduceMotion ? 1 : (pressed ? .975 : (active ? 1.012 : 1)),
      duration: duration,
      curve: pressed ? Curves.easeOut : Curves.easeOutBack,
      child: button,
    );
  }
}
