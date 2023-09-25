import 'package:riverpod_annotation/riverpod_annotation.dart';

class FileDiff extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'ori1': [],
      'ori2': [],
      'common': [],
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
      'list1': [...common, ...list1],
      'list2': [...common, ...list2],
      'whoIsNewer': whoIsNewer
    };
  }

  updateIsNewer(int whoIsNewer) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'list1': state['list1'],
      'list2': state['list2'],
      'whoIsNewer': whoIsNewer
    };
  }

  updateList1(List<String> list) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'list1': list,
      'list2': state['list2'],
      'whoIsNewer': state['whoIsNewer']
    };
  }

  updateList2(List<String> list) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'common': state['common'],
      'list1': state['list1'],
      'list2': list,
      'whoIsNewer': state['whoIsNewer']
    };
  }
}

final fileDiffProvider = NotifierProvider<FileDiff, dynamic>(FileDiff.new);
