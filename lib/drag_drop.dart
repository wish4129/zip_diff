import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zip_diff/file_dff_provider.dart';
import 'package:zip_diff/zip_file_provider.dart';

class DragNDropWidget extends ConsumerStatefulWidget {
  final int index;
  final String name;
  final String display;
  const DragNDropWidget(
      {Key? key,
      required this.index,
      required this.name,
      required this.display})
      : super(key: key);

  @override
  ConsumerState<DragNDropWidget> createState() => _DragNDropWidgetState();
}

class _DragNDropWidgetState extends ConsumerState<DragNDropWidget> {
  bool _dragging = false;
  @override
  Widget build(BuildContext context) {
    return DropTarget(
        onDragDone: (detail) async {
          if (widget.index == 1) {
            final filePath = detail.files[0].path;
            final file1InputStream = InputFileStream(filePath);
            final archive1 = ZipDecoder().decodeBuffer(file1InputStream);
            final files = archive1.files
                .where((file) => !file.name.endsWith('/'))
                .toList();
            final length = files.length;
            _updateProvider(zipOneProvider, ref, detail.files[0], length);
          } else {
            final filePath = detail.files[0].path;
            final file1InputStream = InputFileStream(filePath);
            final archive2 = ZipDecoder().decodeBuffer(file1InputStream);
            final files = archive2.files
                .where((file) => !file.name.endsWith('/'))
                .toList();
            final length = files.length;
            _updateProvider(zipTwoProvider, ref, detail.files[0], length);
          }
        },
        onDragUpdated: (details) => setState(() {}),
        onDragEntered: (detail) => setState(() => _dragging = true),
        onDragExited: (detail) => setState(() => _dragging = false),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: SizedBox(
            width: 200,
            height: 50,
            child: showNames(widget, _dragging),
          ),
        ));
  }
}

void _updateProvider(provider, WidgetRef ref, XFile file, int length) async {
  ref.watch(provider.notifier).updateName(file.name);
  ref.watch(provider.notifier).updateFilePath(file.path);
  ref.watch(provider.notifier).updateSize(await _getFileSize(file.path));
  ref.watch(provider.notifier).updateFilePath(file.path);
  ref.watch(provider.notifier).updateFileCount(length);
  final date =
      DateFormat("yyyy-MM-dd hh:mm a").format(await file.lastModified());
  ref.watch(provider.notifier).updateLastModifiedTime(date);
}

Future<int> _getFileSize(String path) async {
  final fileBytes = await File(path).readAsBytes();
  return fileBytes.lengthInBytes;
}

String formatFileSize(int fileSizeInBytes) {
  const int kilobyte = 1024;
  const int megabyte = kilobyte * 1024;
  const int gigabyte = megabyte * 1024;
  const int terabyte = gigabyte * 1024;
  if (fileSizeInBytes == 0) return '';
  if (fileSizeInBytes >= terabyte) {
    return '${(fileSizeInBytes / terabyte).toStringAsFixed(2)} TB';
  } else if (fileSizeInBytes >= gigabyte) {
    return '${(fileSizeInBytes / gigabyte).toStringAsFixed(2)} GB';
  } else if (fileSizeInBytes >= megabyte) {
    return '${(fileSizeInBytes / megabyte).toStringAsFixed(2)} MB';
  } else if (fileSizeInBytes >= kilobyte) {
    return '${(fileSizeInBytes / kilobyte).toStringAsFixed(2)} KB';
  } else {
    return '$fileSizeInBytes bytes';
  }
}

Widget showNames(DragNDropWidget widget, bool dragging) {
  if (widget.index == 1) {
    return Consumer(builder: (context, ref, child) {
      var zipOne = ref.watch(zipOneProvider);
      return TextField(
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            final filePath = result.files.single.path!;
            final file = XFile(filePath);
            final file1InputStream = InputFileStream(filePath);
            final archive1 = ZipDecoder().decodeBuffer(file1InputStream);
            final files = archive1.files
                .where((file) => !file.name.endsWith('/'))
                .toList();
            final length = files.length;
            _updateProvider(zipOneProvider, ref, file, length);
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Zip ${widget.index}',
        ),
        readOnly: true,
        controller: TextEditingController(
          text: zipOne['name'] != ''
              ? zipOne['name']
              : (dragging ? 'Drop here' : zipOne['name']),
        ),
      );
    });
  } else {
    return Consumer(builder: (context, ref, child) {
      var zipTwo = ref.watch(zipTwoProvider);
      return TextField(
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            final filePath = result.files.single.path!;
            final file = XFile(filePath);
            final file1InputStream = InputFileStream(filePath);
            final archive2 = ZipDecoder().decodeBuffer(file1InputStream);
            final files = archive2.files
                .where((file) => !file.name.endsWith('/'))
                .toList();
            final length = files.length;
            _updateProvider(zipTwoProvider, ref, file, length);
          }
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Zip ${widget.index}',
        ),
        readOnly: true,
        controller: TextEditingController(
          text: zipTwo['name'] != ''
              ? zipTwo['name']
              : (dragging ? 'Drop here' : zipTwo['name']),
        ),
      );
    });
  }
}

Widget getDisplayOne() {
  return Consumer(builder: (context, ref, child) {
    var fileDiff = ref.watch(fileDiffProvider);
    var zipOne = ref.watch(zipOneProvider);
    if (zipOne['last_modified_time'] != '' && fileDiff['whoIsNewer'] == 1) {
      return Text('${zipOne['last_modified_time']} * newer',
          textAlign: TextAlign.center);
    } else {
      return Text(zipOne['last_modified_time'], textAlign: TextAlign.center);
    }
  });
}

Widget getDisplayTwo() {
  return Consumer(builder: (context, ref, child) {
    var fileDiff = ref.watch(fileDiffProvider);
    var zipTwo = ref.watch(zipTwoProvider);
    if (zipTwo['last_modified_time'] != '' && fileDiff['whoIsNewer'] == 2) {
      return Text('${zipTwo['last_modified_time']} * newer',
          textAlign: TextAlign.center);
    } else {
      return Text(zipTwo['last_modified_time'], textAlign: TextAlign.center);
    }
  });
}
