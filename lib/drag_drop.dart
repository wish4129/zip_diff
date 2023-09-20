import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            _updateProvider(zipOneProvider, ref, detail.files[0]);
          } else {
            _updateProvider(zipTwoProvider, ref, detail.files[0]);
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

void _updateProvider(provider, ref, file) async {
  ref.watch(provider.notifier).updateName(file.name);
  ref.watch(provider.notifier).updateFilePath(file.path);
  ref.watch(provider.notifier).updateSize(await _getFileSize(file.path));
  ref.watch(provider.notifier).updateFilePath(file.path);
  ref
      .watch(provider.notifier)
      .updateLastModifiedTime((await file.lastModified()).toIso8601String());
}

Future<int> _getFileSize(String path) async {
  final fileBytes = await File(path).readAsBytes();
  return fileBytes.lengthInBytes;
}

String _formatFileSize(int fileSizeInBytes) {
  const int kilobyte = 1024;
  const int megabyte = kilobyte * 1024;
  const int gigabyte = megabyte * 1024;
  const int terabyte = gigabyte * 1024;

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

Widget listDetails(int index) {
  if (index == 1) {
    return Consumer(builder: (context, ref, child) {
      var fileDiff = ref.watch(fileDiffProvider);
      var zipOne = ref.watch(zipOneProvider);
      return Column(
        children: [
          // Text(zipOne['name'] ?? ' bla '),
          // Text(zipOne['file_path'] ?? ' no file'),
          Text(
              '${zipOne['last_modified_time']} ${fileDiff['isNewer'] == true ? 'Newer' : ''}'),
          // Text(zipOne['size'] != 0 ? _formatFileSize(zipOne['size']) : '0'),
        ],
      );
    });
  } else {
    return Consumer(builder: (context, ref, child) {
      var fileDiff = ref.watch(fileDiffProvider);
      var zipTwo = ref.watch(zipTwoProvider);
      return Column(
        children: [
          // Text(zipTwo['name'] ?? ' bla '),
          // Text(zipTwo['file_path'] ?? ' no file'),
          Text(
              '${zipTwo['last_modified_time']} ${fileDiff['isNewer'] == false ? 'Newer' : ''}'),
          // Text(zipTwo['size'] != 0 ? _formatFileSize(zipTwo['size']) : '0'),
        ],
      );
    });
  }
}
