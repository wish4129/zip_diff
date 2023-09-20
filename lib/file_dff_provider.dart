import 'package:riverpod_annotation/riverpod_annotation.dart';

class FileDiff extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {'ori1': [], 'ori2': [], 'list1': [], 'list2': [], 'isNewer': false};
  }

  updateList(List<String> ori1, List<String> ori2, List<String> list1,
      List<String> list2, bool isNewer) {
    state = {
      'ori1': ori1,
      'ori2': ori2,
      'list1': list1,
      'list2': list2,
      'isNewer': isNewer
    };
  }

  updateIsNewer(bool isNewer) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'list1': state['list1'],
      'list2': state['list2'],
      'isNewer': isNewer
    };
  }

  updateList1(List<String> list) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'list1': list,
      'list2': state['list2'],
      'isNewer': state['isNewer']
    };
  }

  updateList2(List<String> list) {
    return {
      'ori1': state['ori1'],
      'ori2': state['ori2'],
      'list1': state['list1'],
      'list2': list,
      'isNewer': state['isNewer']
    };
  }
}

final fileDiffProvider = NotifierProvider<FileDiff, dynamic>(FileDiff.new);
