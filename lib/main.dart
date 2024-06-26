import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zip_diff/default_theme.dart';
import 'package:zip_diff/drag_drop.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zip_diff/file_diff_provider.dart';
import 'package:zip_diff/ui_provider.dart';
import 'package:zip_diff/zip_file_provider.dart';
import 'package:path_provider/path_provider.dart';

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
    var fileDiff = ref.watch(fileDiffProvider);
    var ui = ref.watch(uiProvider);
    return MaterialApp(
      theme: defaultTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DragNDropWidget(
                      index: 1, name: 'Drop zip here', display: zipOne['name']),
                  DragNDropWidget(
                      index: 2, name: 'Drop zip here', display: zipTwo['name']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Text(zipOne['name'], textAlign: TextAlign.center),
                      const Text('Name', textAlign: TextAlign.center),
                      Text(zipTwo['name'], textAlign: TextAlign.center),
                    ],
                  ),
                  TableRow(
                    children: [
                      Text(formatFileSize(zipOne['size']),
                          textAlign: TextAlign.center),
                      const Text('Size', textAlign: TextAlign.center),
                      Text(formatFileSize(zipTwo['size']),
                          textAlign: TextAlign.center),
                    ],
                  ),
                  TableRow(
                    children: [
                      getDisplayOne(),
                      const Text(
                        'Last Modified Time',
                        textAlign: TextAlign.center,
                      ),
                      getDisplayTwo(),
                    ],
                  ),
                  TableRow(children: [
                    Text(
                        zipOne['file_count'] != 0
                            ? zipOne['file_count'].toString()
                            : '',
                        textAlign: TextAlign.center),
                    const Text(
                      'Total Files',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                        zipTwo['file_count'] != 0
                            ? zipTwo['file_count'].toString()
                            : '',
                        textAlign: TextAlign.center),
                  ])
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Zip 1', style: defaultTheme.textTheme.bodyLarge),
                    Text(
                      'Files Difference',
                      style: defaultTheme.textTheme.bodyLarge,
                    ),
                    Text('Zip 2', style: defaultTheme.textTheme.bodyLarge),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: ui['onlyShowDiff'],
                    onChanged: (bool? value) {
                      ref.watch(uiProvider.notifier).updateOnlyShowDiff(value!);
                      ref.read(fileDiffProvider.notifier).updateList1(value);
                      ref.read(fileDiffProvider.notifier).updateList2(value);
                      final commonLength = fileDiff['common'].length;
                      final uniqueLength1 = fileDiff['unique1'].length;
                      final uniqueLength2 = fileDiff['unique2'].length;
                      var length1 = 0;
                      var length2 = 0;
                      if (value == false) {
                        length1 = commonLength + uniqueLength1;
                        length2 = commonLength + uniqueLength2;
                      } else {
                        length1 = commonLength;
                        length2 = commonLength;
                      }
                      ref.read(uiProvider.notifier).defineCheckBoxes1(length1);
                      ref.read(uiProvider.notifier).defineCheckBoxes2(length2);
                    },
                  ),
                  const Text('Only show different files'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 20, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      height: 260,
                      padding: const EdgeInsets.only(right: 10.0),
                      child: listOne(ref, ui),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[300],
                      height: 260,
                      padding: const EdgeInsets.only(left: 10.0),
                      child: listTwo(ref, ui),
                    ),
                  ),
                ],
              ),
            ),
            // Row with 2 round buttons, 1 with compare icon, 1 with export icon
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => onCompare(zipOne, zipTwo, ref),
                    child: const Column(
                      children: [
                        Icon(Icons.compare),
                        Text('Compare'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => onExport(ref),
                    child: const Column(
                      children: [
                        Icon(Icons.folder_zip),
                        Text('Export'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => onPressed(zipOne, zipTwo, ref),
        //   child: const Icon(Icons.compare),
        // ),
      ),
    );
  }
}

void onCompare(zipOne, zipTwo, WidgetRef ref) {
  if (zipOne['file_path'] == "" || zipTwo['file_path'] == "") {
    return;
  }
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
    if (!files2.contains(file)) unique1.add(file);
  }

  for (var file in files2) {
    if (!files1.contains(file)) unique2.add(file);
  }

  List<String> common = getSimilarFiles(archive1.files, archive2.files);
  var date1 = DateFormat("yyyy-MM-dd hh:mm a")
      .parse(ref.watch(zipOneProvider)['last_modified_time']);
  var date2 = DateFormat("yyyy-MM-dd hh:mm a")
      .parse(ref.watch(zipTwoProvider)['last_modified_time']);
  int whoIsNewer;
  if (date1.isAfter(date2)) {
    whoIsNewer = 1;
  } else {
    whoIsNewer = 2;
  }
  ref
      .read(fileDiffProvider.notifier)
      .updateList(files1, files2, common, unique1, unique2, whoIsNewer);

  ref.read(uiProvider.notifier).defineCheckBoxes1(files1.length);
  ref.read(uiProvider.notifier).defineCheckBoxes2(files2.length);
}

void onExport(WidgetRef ref) async {
  var ui = ref.watch(uiProvider);
  var fileDiff = ref.watch(fileDiffProvider);
  var zipOne = ref.watch(zipOneProvider);
  var zipTwo = ref.watch(zipTwoProvider);
  List<String> filesToZip = [];
  for (var i = 0; i < ui['checkBoxes1'].length; i++) {
    if (ui['checkBoxes1'][i] == true) {
      filesToZip.add(fileDiff['list1'][i]);
    }
  }
  for (var i = 0; i < ui['checkBoxes2'].length; i++) {
    // don't add the file if it's already in the array
    if (ui['checkBoxes2'][i] == true &&
        !filesToZip.contains(fileDiff['list2'][i])) {
      filesToZip.add(fileDiff['list2'][i]);
    }
  }

  if (filesToZip.isEmpty) return;

  final inputStream1 = InputFileStream(zipOne['file_path']);
  final archive1 = ZipDecoder().decodeBuffer(inputStream1);
  final inputStream2 = InputFileStream(zipTwo['file_path']);
  final archive2 = ZipDecoder().decodeBuffer(inputStream2);

  final docDir = (await getApplicationDocumentsDirectory()).path;
  // add files from zip1 to out folder
  for (var file in archive1.files) {
    if (filesToZip.contains(file.name)) {
      if (file.isFile) {
        final outputStream = OutputFileStream('$docDir/out/${file.name}');
        file.writeContent(outputStream);
        outputStream.close();
      }
    }
  }

  // add files from zip2 to out folder
  for (var file in archive2.files) {
    if (filesToZip.contains(file.name)) {
      if (file.isFile) {
        final outputStream = OutputFileStream('$docDir/out/${file.name}');
        file.writeContent(outputStream);
        outputStream.close();
      }
    }
  }

  var encoder = ZipFileEncoder();
  encoder.create('$docDir/export.zip');
  final outDir = Directory('$docDir/out');
  final outFiles = outDir.listSync(recursive: true);
  for (var file in outFiles) {
    if (file is File) {
      final filePath = file.path;
      final fileName = getRelativePath(filePath, docDir);
      encoder.addFile(File(filePath), fileName);
    }
  }
  encoder.close();
  outDir.deleteSync(recursive: true);
  Process.run('open', [docDir]);
}

String getRelativePath(String filePath, String docDir) {
  List<String> filePathParts = filePath.split('/');
  int outIndex = filePathParts.indexWhere((part) => part == 'out');
  List<String> relativeParts = filePathParts.sublist(outIndex + 1);
  String relativePath = relativeParts.join('/');
  return relativePath;
}

Widget listOne(WidgetRef ref, ui) {
  var fileDiff = ref.watch(fileDiffProvider);
  List<Widget> list = [];
  for (var item in fileDiff['list1']) {
    if (fileDiff['common'].contains(item)) {
      list.add(SizedBox(
          height: 20,
          child: Row(
            children: [
              Checkbox(
                  value: ui['checkBoxes1'][fileDiff['list1'].indexOf(item)],
                  onChanged: (bool? value) {
                    ref.read(uiProvider.notifier).updateCheckBoxes1(
                        fileDiff['list1'].indexOf(item), value!, true);
                  }),
              Text(item),
            ],
          )));
    } else {
      list.add(SizedBox(
          height: 20,
          child: Row(
            children: [
              Checkbox(
                  value: ui['checkBoxes1'][fileDiff['list1'].indexOf(item)],
                  onChanged: (bool? value) {
                    ref.read(uiProvider.notifier).updateCheckBoxes1(
                        fileDiff['list1'].indexOf(item), value!, false);
                  }),
              Text('*$item'),
            ],
          )));
    }
  }
  return ListView(children: list);
}

Widget listTwo(WidgetRef ref, ui) {
  var fileDiff = ref.watch(fileDiffProvider);
  List<Widget> list = [];
  for (var item in fileDiff['list2']) {
    if (fileDiff['common'].contains(item)) {
      list.add(SizedBox(
          height: 20,
          child: Row(
            children: [
              Checkbox(
                  value: ui['checkBoxes2'][fileDiff['list2'].indexOf(item)],
                  onChanged: (bool? value) {
                    ref.read(uiProvider.notifier).updateCheckBoxes2(
                        fileDiff['list2'].indexOf(item), value!, true);
                  }),
              Text(item),
            ],
          )));
    } else {
      list.add(SizedBox(
          height: 20,
          child: Row(
            children: [
              Checkbox(
                  value: ui['checkBoxes2'][fileDiff['list2'].indexOf(item)],
                  onChanged: (bool? value) {
                    ref.read(uiProvider.notifier).updateCheckBoxes2(
                        fileDiff['list2'].indexOf(item), value!, false);
                  }),
              Text('*$item'),
            ],
          )));
    }
  }
  return ListView(children: list);
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
