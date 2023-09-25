import 'package:flutter_riverpod/flutter_riverpod.dart';

class UI extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'onlyShowDiff': false,
    };
  }

  updateOnlyShowDiff(bool onlyShowDiff) {
    state = {
      'onlyShowDiff': onlyShowDiff,
    };
  }
}

final uiProvider = NotifierProvider<UI, dynamic>(UI.new);
