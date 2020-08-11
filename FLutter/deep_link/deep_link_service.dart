import 'dart:async';

import 'package:datenspendeausweis/configs/exceptions.dart';
import 'package:datenspendeausweis/utils/log_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:uni_links/uni_links.dart';

/// Need to install package uni_links for usage

class DeepLinkService {
  static const String _kScheme = 'YOUR_SCHEME';
  static const String _kHost = 'YOUR_HOST';
  static const String _kDeepLink = '$_kScheme://$_kHost';
  static const String kRedirectUri = '&redirect_uri=$_kDeepLink';

  /// Returns a [Function], which completes to one of the following:
  ///
  ///   * if bool is true - source was connected, else - revoked;
  ///   Based on the initial link value.
  ///   If the event comes not from Chromium/Safari browser, the app will be reopened
  ///   and initial link will not be null.
  Function(BuildContext, bool) onInitialLinkOpened;

  /// Returns a [Function], which completes to one of the following:
  ///
  ///   * if bool is true - source was connected, else - revoked;
  ///   Based on the link stream value.
  ///   If the event comes from Chromium/Safari browser, the app will not reopened again
  ///   but will be redirected to appropriate screen, specified in the callback.
  Function(BuildContext, bool) onLinkStreamOpened;

  Function(Error) onDeepLinkError;

  StreamSubscription _sub;

  void launch(BuildContext context) async {
    try {
      final initialString = await getInitialLink();
      LogUtils.debug(
          runtimeType.toString(), 'launch::initialString', initialString);
      onInitialLinkOpened(context, _isConnected(initialString));
    } catch (e) {
      onDeepLinkError(e);
    }
    _sub = getLinksStream().listen((String link) {
      try {
        LogUtils.debug(runtimeType.toString(), 'launch::linkStream', link);
        onLinkStreamOpened(context, _isConnected(link));
      } catch (e) {
        onDeepLinkError(e);
      }
    }, onError: (e) => onDeepLinkError(e));
  }

  void cancel() async {
    LogUtils.debug(runtimeType.toString(), 'cancel', 'deep link service sub');
    if (_sub != null) {
      await _sub.cancel();
    }
  }

  bool _isConnected(String link) {
    if (link.contains(_kDeepLink)) {
      return Uri.parse(link).queryParameters['connected'] == 'true';
    } else {
      throw ConnectionException(
          'Url does not contain information about connection');
    }
  }
}
