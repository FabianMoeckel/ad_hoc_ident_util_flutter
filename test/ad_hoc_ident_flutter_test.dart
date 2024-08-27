import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_util_flutter/ad_hoc_ident_util_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('successfully apply inner detector', () async {
    const testIdentity =
        AdHocIdentity(type: "testType", identifier: "testIdentifier");
    final mockDetector = AdHocIdentityDetector.fromDelegate(
      (input) async => testIdentity,
    );
    final detector = BackgroundIdentityDetector(mockDetector);

    final result = await detector.detect("someInput");

    expect(result, testIdentity);
  });

  test('fail when passing invalid type to isolate', () async {
    final completer = Completer<AdHocIdentity>();
    const testIdentity =
        AdHocIdentity(type: "testType", identifier: "testIdentifier");
    final mockDetector = AdHocIdentityDetector.fromDelegate(
      (input) => completer.future,
    );
    final detector = BackgroundIdentityDetector(mockDetector);
    completer.complete(testIdentity);

    var future = detector.detect("someInput");

    // AsyncCompleter object is unsendable
    await expectLater(future, throwsA(isA<ArgumentError>()));
  });
}
