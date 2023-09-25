import 'package:riverpod_annotation/riverpod_annotation.dart';

class FileDiff extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'ori1': [],
      'ori2': [],
      'common': [],
      'unique1': [],
      'unique2': [],
      'list1': [],
      'list2': [],
      'whoIsNewer': 0
    };
  }

  updateList(List<String> ori1, List<String> ori2, List<String> common,
      List<String> list1, List<String> list2, int whoIsNewer) {
    state = {
      'ori1': ori1,
      'ori2': ori2,
      'common': common,
      'unique1': list1,
      'unique2': list2,
      'list1': [...common, ...list1],
      'list2': [...common, ...list2],
      'whoIsNewer': whoIsNewer
    };
  }

  updateIsNewer(int whoIsNewer) {
    state = {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'unique1': state['unique1'],
      'unique2': state['unique2'],
      'list1': state['list1'],
      'list2': state['list2'],
      'whoIsNewer': whoIsNewer
    };
  }

  updateList1(bool onlyShowDiff) {
    var list = [];
    if (onlyShowDiff) {
      list = state['unique1'];
    } else {
      list = [...state['common'], ...state['unique1']];
    }
    state = {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'unique1': state['unique1'],
      'unique2': state['unique2'],
      'list1': list,
      'list2': state['list2'],
      'whoIsNewer': state['whoIsNewer']
    };
  }

  updateList2(bool onlyShowDiff) {
    var list = [];
    if (onlyShowDiff) {
      list = state['unique2'];
    } else {
      list = [...state['common'], ...state['unique2']];
    }
    state = {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'unique1': state['unique1'],
      'unique2': state['unique2'],
      'list1': state['list1'],
      'list2': list,
      'whoIsNewer': state['whoIsNewer']
    };
  }
}

final fileDiffProvider = NotifierProvider<FileDiff, dynamic>(FileDiff.new);
