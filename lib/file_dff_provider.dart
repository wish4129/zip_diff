import 'package:riverpod_annotation/riverpod_annotation.dart';

class FileDiff extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'list1': [],
      'list2': [],
    };
  }

  updateList(List<String> list1, List<String> list2) {
    state = {
      'list1': list1,
      'list2': list2,
    };
  }

  updateList1(List<String> list) {
    return {
      'list1': list,
      'list2': state['list2'],
    };
  }

  updateList2(List<String> list) {
    return {
      'list1': state['list1'],
      'list2': list,
    };
  }
}

final fileDiffProvider = NotifierProvider<FileDiff, dynamic>(FileDiff.new);
