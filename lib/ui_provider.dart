import 'package:flutter_riverpod/flutter_riverpod.dart';

class UI extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'onlyShowDiff': false,
      'checkBoxes1': [],
      'checkBoxes2': [],
    };
  }

  updateOnlyShowDiff(bool onlyShowDiff) {
    state = {
      'onlyShowDiff': onlyShowDiff,
      'checkBoxes1': state['checkBoxes'],
      'checkBoxes2': state['checkBoxes'],
    };
  }

  defineCheckBoxes1(int length) {
    state = {
      'onlyShowDiff': state['onlyShowDiff'],
      'checkBoxes1': List<bool>.filled(length, false),
      'checkBoxes2': state['checkBoxes2'],
    };
  }

  defineCheckBoxes2(int length) {
    state = {
      'onlyShowDiff': state['onlyShowDiff'],
      'checkBoxes1': state['checkBoxes1'],
      'checkBoxes2': List<bool>.filled(length, false),
    };
  }

  updateCheckBoxes1(int index, bool value, bool isCommon) {
    var newCheckBoxes1 = state['checkBoxes1'];
    var newCheckBoxes2 = state['checkBoxes2'];
    newCheckBoxes1[index] = value;
    if (isCommon) {
      newCheckBoxes2[index] = value;
    }
    state = {
      'onlyShowDiff': state['onlyShowDiff'],
      'checkBoxes1': newCheckBoxes1,
      'checkBoxes2': newCheckBoxes2,
    };
  }

  updateCheckBoxes2(int index, bool value, bool isCommon) {
    var newCheckBoxes1 = state['checkBoxes1'];
    var newCheckBoxes2 = state['checkBoxes2'];
    newCheckBoxes2[index] = value;
    if (isCommon) {
      newCheckBoxes1[index] = value;
    }
    state = {
      'onlyShowDiff': state['onlyShowDiff'],
      'checkBoxes1': state['checkBoxes1'],
      'checkBoxes2': newCheckBoxes2,
    };
  }
}

final uiProvider = NotifierProvider<UI, dynamic>(UI.new);
