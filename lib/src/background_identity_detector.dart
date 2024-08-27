import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Wraps an [AdHocIdentityDetector] to execute its detection by passing it to [compute].
class BackgroundIdentityDetector<TInput>
    implements AdHocIdentityDetector<TInput> {
  /// The [AdHocIdentityDetector] actually performing the detection.
  final AdHocIdentityDetector<TInput> innerDetector;

  /// Creates a new [BackgroundIdentityDetector]
  /// wrapping an existing [innerDetector].
  ///
  /// Be aware of the restrictions listed at `SendPort.send()` documentation
  /// for more information. If the [innerDetector] tries to pass one of those
  /// types to the compute function, the detector will throw when trying to
  /// [detect].
  BackgroundIdentityDetector(this.innerDetector);

  @override
  Future<AdHocIdentity?> detect(TInput input) async {
    // pass the root isolate token to avoid issues when calling plugins
    final token = RootIsolateToken.instance!;
    final identity =
        await compute(_detect, _IsolateData(token: token, input: input));
    return identity;
  }

  _detect(_IsolateData data) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
    final identity = await innerDetector.detect(data.input);
    return identity;
  }
}

class _IsolateData<TInput> {
  final RootIsolateToken token;
  final TInput input;

  _IsolateData({required this.token, required this.input});
}
