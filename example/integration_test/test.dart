import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viam_example_app/main.dart';
import 'package:integration_test/integration_test.dart';

Future<Finder> awaitWidget(WidgetTester tester, Finder finder) async {
  final durt = Duration(seconds: 60); // todo: take as arg
  final end = DateTime.now().add(durt);
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) return finder;
    await Future.delayed(Duration(milliseconds: 100));
  }
  throw TimeoutException("finder: $finder", durt);
}

const btDeviceName = 'aw-rpi-6';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('provisioning', () {
    testWidgets('new-machine-tether', (
      tester,
    ) async {
      // Load app widget.
      await tester.pumpWidget(const MyApp());

      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('new-machine-flow'))));
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('start-tethering'))));
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('screen-1-cta'))));

      await tester.pumpAndSettle(); // otherwise cta is offscreen
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('screen-2-cta'))));

      await tester.tap(await awaitWidget(
          tester,
          find.ancestor(
            of: find.text(btDeviceName),
            matching: find.byKey(ValueKey('device-tile')),
          )));

      await tester.pumpAndSettle();
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('tether-method'))));
      await tester.pumpAndSettle();
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('next'))));
      await tester.pumpAndSettle();
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('confirm-hotspot'))));

      debugPrint("TESTER: MANUALLY PAIR NOW");
      await Future.delayed(Duration(seconds: 10));
      await tester.tap(await awaitWidget(tester, find.byKey(const ValueKey('confirm-paired'))));

      // next two are states not buttons; is there a better way to await them?
      // todo: shorter waits except for these two and the device-tile
      await awaitWidget(tester, find.byKey(const ValueKey('online-state')));
      await awaitWidget(tester, find.byKey(const ValueKey('device-connected-viam')));
    });
  });
}
