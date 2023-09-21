import 'package:flutter/material.dart';
import 'package:zip_diff/drag_drop.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zip_diff/file_dff_provider.dart';
import 'package:zip_diff/zip_file_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    var zipOne = ref.watch(zipOneProvider);
    var zipTwo = ref.watch(zipTwoProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DragNDropWidget(
                    index: 1, name: 'Drop zip here', display: zipOne['name']),
                DragNDropWidget(
                    index: 2, name: 'Drop zip here', display: zipTwo['name']),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      const Text('Name'),
                      Text(zipOne['name']),
                      Text(zipTwo['name']),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Size'),
                      Text(formatFileSize(zipOne['size'])),
                      Text(formatFileSize(zipTwo['size'])),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Last Modified Time'),
                      getDisplayOne(),
                      getDisplayTwo(),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.only(right: 10.0),
                      color: Colors.green.withOpacity(0.4),
                      child: ListView(shrinkWrap: true, children: [
                        for (var item in ref.watch(fileDiffProvider)['ori1'])
                          ListTile(title: Text(item)),
                        for (var item in ref.watch(fileDiffProvider)['list1'])
                          ListTile(title: Text('* $item'))
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.only(left: 10.0),
                      color: Colors.blue.withOpacity(0.4),
                      child: ListView(shrinkWrap: true, children: [
                        for (var item in ref.watch(fileDiffProvider)['ori2'])
                          ListTile(title: Text(item)),
                        for (var item in ref.watch(fileDiffProvider)['list2'])
                          ListTile(title: Text('* $item'))
                      ]),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => onPressed(zipOne, zipTwo, ref),
          backgroundColor: Colors.green,
          child: const Icon(Icons.compare),
        ),
      ),
    );
  }
}

void onPressed(zipOne, zipTwo, WidgetRef ref) {
  final file1InputStream = InputFileStream(zipOne['file_path']);
  final archive1 = ZipDecoder().decodeBuffer(file1InputStream);
  final file2InputStream = InputFileStream(zipTwo['file_path']);
  final archive2 = ZipDecoder().decodeBuffer(file2InputStream);
  List<String> files1 = archive1.files
      .where((file) => file.isFile)
      .map((file) => file.name)
      .toList();
  List<String> files2 = archive2.files
      .where((file) => file.isFile)
      .map((file) => file.name)
      .toList();

  List<String> ori1 = [];
  List<String> ori2 = [];
  List<String> array1 = [];
  List<String> array2 = [];

  for (var file in files1) {
    if (!files2.contains(file)) {
      array1.add(file);
    } else {
      ori1.add(file);
    }
  }

  for (var file in files2) {
    if (!files1.contains(file)) {
      array2.add(file);
    } else {
      ori2.add(file);
    }
  }

  var date1 = DateTime.parse(ref.watch(zipOneProvider)['last_modified_time']);
  var date2 = DateTime.parse(ref.watch(zipTwoProvider)['last_modified_time']);
  int whoIsNewer;
  if (date1.isAfter(date2)) {
    whoIsNewer = 1;
  } else {
    whoIsNewer = 2;
  }
  ref
      .read(fileDiffProvider.notifier)
      .updateList(ori1, ori2, array1, array2, whoIsNewer);
}
