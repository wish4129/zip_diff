import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zip_diff/zip_first_provider.dart';

class DragNDropWidget extends ConsumerStatefulWidget {
  final int index;
  String name;
  DragNDropWidget({Key? key, required this.index, required this.name})
      : super(key: key);

  @override
  ConsumerState<DragNDropWidget> createState() => _DragNDropWidgetState();
}

class _DragNDropWidgetState extends ConsumerState<DragNDropWidget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    var zipOne = ref.watch(zipOneProvider);
    var zipTwo = ref.watch(zipTwoProvider);
    return DropTarget(
      onDragDone: (detail) async {
        debugPrint('onDragDone:');
        if (widget.index == 1) {
          ref.watch(zipOneProvider.notifier).updateName(detail.files[0].name);
        } else {
          ref.watch(zipTwoProvider.notifier).updateName(detail.files[0].name);
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
        child: Stack(
          children: [
            Center(
                child: Text(widget.index == 1
                    ? (zipOne['name'] != '' ? zipOne['name'] : widget.name)
                    : (zipTwo['name'] != '' ? zipTwo['name'] : widget.name)))
          ],
        ),
      ),
    );
  }
}
