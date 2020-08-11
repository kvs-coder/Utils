import 'package:datenspendeausweis/service/deep_link_service.dart';
import 'package:datenspendeausweis/view/mixins/deep_link_mixin.dart';
import 'package:flutter/material.dart';

class DeepLinkUtils {
  static DeepLinkService _service;

  static void launch(BuildContext context, DeepLink delegate) {
    if (_service != null) {
      _stop();
    }
    _service = DeepLinkService();
    _service.onInitialLinkOpened = delegate.onInitialLinkOpened;
    _service.onLinkStreamOpened = delegate.onLinkStreamOpened;
    _service.onDeepLinkError = delegate.onDeepLinkError;
    _service.launch(context);
  }

  static void _stop() {
    _service.cancel();
    _service = null;
  }
}
