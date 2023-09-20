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
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 300,
                    color: Colors.green.withOpacity(0.4),
                    child: Center(
                        child: ListView(children: [
                      for (var item in ref.watch(fileDiffProvider)['list1'])
                        Text(item),
                    ])),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 300,
                    color: Colors.blue.withOpacity(0.4),
                    child: Center(
                        child: ListView(children: [
                      for (var item in ref.watch(fileDiffProvider)['list2'])
                        Text(item),
                    ])),
                  ),
                ),
              ],
            )
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final file1InputStream = InputFileStream(zipOne['file_path']);
            final archive1 = ZipDecoder().decodeBuffer(file1InputStream);
            final file2InputStream = InputFileStream(zipTwo['file_path']);
            final archive2 = ZipDecoder().decodeBuffer(file2InputStream);
            List<String> files1 = [];
            List<String> files2 = [];
            for (var file in archive1.files) {
              if (file.isFile) {
                debugPrint(
                    'archive1 ${file.name} ${file.lastModTime.toString()}');
                files1.add(file.name);
                // final outputStream = OutputFileStream('out/${file.name}');
                // file.writeContent(outputStream);
                // outputStream.close();
              }
            }
            for (var file in archive2.files) {
              if (file.isFile) {
                debugPrint(
                    'archive2 ${file.name} ${file.lastModTime.toString()}');
                files2.add(file.name);
                // final outputStream = OutputFileStream('out/${file.name}');
                // file.writeContent(outputStream);
                // outputStream.close();
              }
            }
            compareArrays(files1, files2, ref);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.compare),
        ),
      ),
    );
  }
}

void compareArrays(List<String> files1, List<String> files2, WidgetRef ref) {
  List<String> array1 = [];
  List<String> array2 = [];

  for (var file in files1) {
    if (!files2.contains(file)) {
      array1.add(file);
    }
  }

  for (var file in files2) {
    if (!files1.contains(file)) {
      array2.add(file);
    }
  }
  ref.read(fileDiffProvider.notifier).updateList(array1, array2);
}
