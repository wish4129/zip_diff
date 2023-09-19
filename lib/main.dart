import 'package:flutter/material.dart';
import 'package:zip_diff/drag_drop.dart';
import 'package:archive/archive_io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DragNDropWidget(text: 'Zip File 1'),
                DragNDropWidget(text: 'Zip File 2'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.blue.withOpacity(0.4),
                    child: const Center(child: Text('Diff')),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.blue.withOpacity(0.4),
                    child: const Center(child: Text('Diff')),
                  ),
                ),
              ],
            )
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final file1InputStream = InputFileStream(
                '/Users/munkevin/Desktop/Sirius Code/SwpSql_1.0.6.zip');
            final archive1 = ZipDecoder().decodeBuffer(file1InputStream);
            final file2InputStream = InputFileStream(
                '/Users/munkevin/Desktop/Sirius Code/SwpSql_1.0.7.zip');
            final archive2 = ZipDecoder().decodeBuffer(file2InputStream);
            List<String> files1 = [];
            List<String> files2 = [];
            for (var file in archive1.files) {
              if (file.isFile) {
                print('archive1 ${file.name} ${file.lastModTime.toString()}');
                files1.add(file.name);
                // final outputStream = OutputFileStream('out/${file.name}');
                // file.writeContent(outputStream);
                // outputStream.close();
              }
            }
            for (var file in archive2.files) {
              if (file.isFile) {
                print('archive2 ${file.name} ${file.lastModTime.toString()}');
                files2.add(file.name);
                // final outputStream = OutputFileStream('out/${file.name}');
                // file.writeContent(outputStream);
                // outputStream.close();
              }
            }
            final zz = compareArrays(files1, files2);
            print(zz[0]);
            print(zz[1]);
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.compare),
        ),
      ),
    );
  }
}

List<List<String>> compareArrays(List<String> files1, List<String> files2) {
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

  return [array1, array2];
}
