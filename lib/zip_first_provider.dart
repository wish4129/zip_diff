import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class ZipFile extends Notifier<dynamic> {
  @override
  dynamic build() {
    return {
      'name': '',
      'last_modified_time': '',
      'size': 0,
      'files': [],
      'files_last_modified_time': [],
      'file_size': [],
    };
  }

  updateName(String name) {
    state = {
      'name': name,
      'last_modified_time': state['last_modified_time'],
      'size': state['size'],
      'files': state['files'],
      'files_last_modified_time': state['files_last_modified_time'],
      'file_size': state['file_size'],
    };
  }

  updateMessage(String lastModifiedTime) {
    state = {
      'name': state['name'],
      'last_modified_time': lastModifiedTime,
      'size': state['size'],
      'files': state['files'],
      'files_last_modified_time': state['files_last_modified_time'],
      'file_size': state['file_size'],
    };
  }

  updateSize(int size) {
    state = {
      'name': state['name'],
      'last_modified_time': state['last_modified_time'],
      'size': size,
      'files': state['files'],
      'files_last_modified_time': state['files_last_modified_time'],
      'file_size': state['file_size'],
    };
  }

  updateFiles(List<String> files) {
    state = {
      'name': state['name'],
      'last_modified_time': state['last_modified_time'],
      'size': state['size'],
      'files': files,
      'files_last_modified_time': state['files_last_modified_time'],
      'file_size': state['file_size'],
    };
  }

  updateLastModifiedTime(List<String> filesLastModifiedTime) {
    state = {
      'name': state['name'],
      'last_modified_time': state['last_modified_time'],
      'size': state['size'],
      'files': state['files'],
      'files_last_modified_time': filesLastModifiedTime,
      'file_size': state['file_size'],
    };
  }

  updateFilesSize(List<int> filesSize) {
    state = {
      'name': state['name'],
      'last_modified_time': state['last_modified_time'],
      'size': state['size'],
      'files': state['files'],
      'files_last_modified_time': state['files_last_modified_time'],
      'file_size': filesSize,
    };
  }
}

final zipOneProvider = NotifierProvider<ZipFile, dynamic>(ZipFile.new);
final zipTwoProvider = NotifierProvider<ZipFile, dynamic>(ZipFile.new);
