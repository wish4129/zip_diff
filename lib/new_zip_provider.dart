import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewZip extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'name': '',
      'files': [],
    };
  }

  updateName(String name) {
    state = {
      'name': name,
      'files': [],
    };
  }

  addFile(String fileName) {
    if (!state['files'].contains(fileName)) state['files'].add(fileName);
  }

  removeFile(String fileName) {
    if (state['files'].contains(fileName)) state['files'].remove(fileName);
  }
}

final newZipProvider = NotifierProvider<NewZip, dynamic>(NewZip.new);
