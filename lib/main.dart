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
                      child: ListView(shrinkWrap: true, children: [
                        for (var item in ref.watch(fileDiffProvider)['common'])
                          SizedBox(height: 20, child: Text(item)),
                        for (var item in ref.watch(fileDiffProvider)['list1'])
                          SizedBox(height: 20, child: Text('*$item')),
                      ]),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListView(shrinkWrap: true, children: [
                        for (var item in ref.watch(fileDiffProvider)['common'])
                          SizedBox(height: 20, child: Text(item)),
                        for (var item in ref.watch(fileDiffProvider)['list2'])
                          SizedBox(height: 20, child: Text('*$item')),
                      ]),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => onPressed(zipOne, zipTwo, ref),
          backgroundColor: const Color.fromARGB(255, 252, 185, 56),
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

  List<String> unique1 = [];
  List<String> unique2 = [];

  for (var file in files1) {
    if (!files2.contains(file)) {
      unique1.add(file);
    }
  }

  for (var file in files2) {
    if (!files1.contains(file)) {
      unique2.add(file);
    }
  }

  List<String> common = getSimilarFiles(archive1.files, archive2.files);
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
      .updateList(files1, files2, common, unique1, unique2, whoIsNewer);
}

List<String> getSimilarFiles(
    List<ArchiveFile> files1, List<ArchiveFile> files2) {
  List<String> filesC = [];

  final map1 = {for (var file in files1) file.name: file};
  final map2 = {for (var file in files2) file.name: file};

  for (var name in map1.keys) {
    if (map2.containsKey(name)) {
      ArchiveFile file1 = map1[name]!;
      ArchiveFile file2 = map2[name]!;
      if (file1.lastModTime == file2.lastModTime) {
        filesC.add(name);
      }
    }
  }
  return filesC;
}
