import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zip_diff/zip_file_provider.dart';

class DragNDropWidget extends ConsumerStatefulWidget {
  final int index;
  final String name;
  const DragNDropWidget({Key? key, required this.index, required this.name})
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
        debugPrint('onDragDone:');
        if (widget.index == 1) {
          ref.watch(zipOneProvider.notifier).updateName(detail.files[0].name);
          // update file path
          ref
              .watch(zipOneProvider.notifier)
              .updateFilePath(detail.files[0].path);
          int number = await _getFileSize(detail.files[0].path);
          debugPrint('number: $number');
          ref.watch(zipOneProvider.notifier).updateSize(number);
          ref
              .watch(zipOneProvider.notifier)
              .updateFilePath(detail.files[0].path);
        } else {
          ref.watch(zipTwoProvider.notifier).updateName(detail.files[0].name);
          // update file path
          ref
              .watch(zipTwoProvider.notifier)
              .updateFilePath(detail.files[0].path);
          int number = await _getFileSize(detail.files[0].path);
          debugPrint('number: $number');
          ref.watch(zipTwoProvider.notifier).updateSize(number);
          ref
              .watch(zipTwoProvider.notifier)
              .updateFilePath(detail.files[0].path);
        }
        // for (final file in detail.files) {
        //   debugPrint('  ${file.path} ${file.name}'
        //       '  ${await file.lastModified()}'
        //       '  ${await file.length()}'
        //       '  ${file.mimeType}');
        // }
      },
      onDragUpdated: (details) {
        setState(() {});
      },
      onDragEntered: (detail) {
        setState(() => _dragging = true);
      },
      onDragExited: (detail) {
        setState(() => _dragging = false);
      },
      child: Container(
          height: 200,
          width: 200,
          color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.grey,
          child: listDetails(widget.index, widget)),
    );
  }
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

Widget listDetails(int index, DragNDropWidget widget) {
  if (index == 1) {
    return Consumer(builder: (context, ref, child) {
      var zipOne = ref.watch(zipOneProvider);
      return Column(
        children: [
          Text(zipOne['name'] != '' ? zipOne['name'] : widget.name),
          Text(zipOne['file_path']),
          Text(_formatFileSize(zipOne['size'])),
        ],
      );
    });
  } else {
    return Consumer(builder: (context, ref, child) {
      var zipTwo = ref.watch(zipTwoProvider);
      return Column(
        children: [
          Text(zipTwo['name'] != '' ? zipTwo['name'] : widget.name),
          Text(zipTwo['file_path']),
          Text(_formatFileSize(zipTwo['size'])),
        ],
      );
    });
  }
}
