import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front_check/features/onboarding/presentation/widgets/welcome_action_button.dart';

Widget harness(
    {required VoidCallback onPressed,
    bool primary = true,
    bool reduceMotion = false,
    String label = 'continuar'}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: 350,
            child: WelcomeActionButton(
              label: label,
              primary: primary,
              height: 72,
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {

  testWidgets('press shrinks, cancel restores, and a tap fires exactly once',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(harness(onPressed: () => taps++));
    await tester.pumpAndSettle();
    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(ElevatedButton)));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        lessThan(1));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('hover moves the arrow and resets on exit', (tester) async {
    await tester.pumpWidget(harness(onPressed: () {}));
    await tester.pumpAndSettle();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(ElevatedButton)));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset.dx,
        greaterThan(0));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
        Offset.zero);
    await mouse.removePointer();
  });

  testWidgets('secondary action is keyboard accessible', (tester) async {
    var taps = 0;
    await tester.pumpWidget(harness(primary: false, onPressed: () => taps++));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('Reduce Motion disables entry and press movement',
      (tester) async {
    await tester.pumpWidget(harness(reduceMotion: true, onPressed: () {}));
    expect(tester.widget<Opacity>(find.byType(Opacity).first).opacity, 1);
    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(ElevatedButton)));
    await tester.pump();
    final animation = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(animation.scale, 1);
    expect(animation.duration, Duration.zero);
    expect(tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset,
        Offset.zero);
    await gesture.cancel();
    await tester.pumpAndSettle();
  });

  testWidgets(
      'iOS creates UIKit button, forwards taps, updates, and disposes channel',
      (tester) async {
    final messenger = tester.binding.defaultBinaryMessenger;
    const codec = StandardMethodCodec();
    String? channelName;
    final updates = <MethodCall>[];
    var taps = 0;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views,
        (call) async {
      if (call.method == 'create') {
        final args = call.arguments as Map;
        expect(args['viewType'], 'habitacheck/welcome_button');
        channelName = 'habitacheck/welcome_button/${args['id']}';
        messenger.setMockMethodCallHandler(MethodChannel(channelName!),
            (call) async {
          updates.add(call);
          return null;
        });
      }
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      if (channelName != null) {
        messenger.setMockMethodCallHandler(MethodChannel(channelName!), null);
      }
    });
    await tester.pumpWidget(harness(onPressed: () => taps++));
    await tester.pumpAndSettle();
    expect(find.byType(UiKitView), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    await messenger.handlePlatformMessage(
        channelName!, codec.encodeMethodCall(const MethodCall('tap')), (_) {});
    expect(taps, 1);
    await tester
        .pumpWidget(harness(label: 'nuevo título', onPressed: () => taps++));
    await tester.pumpAndSettle();
    expect((updates.last.arguments as Map)['label'], 'nuevo título');
    await tester.pumpWidget(const SizedBox());
    await messenger.handlePlatformMessage(
        channelName!, codec.encodeMethodCall(const MethodCall('tap')), (_) {});
    expect(taps, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
}
