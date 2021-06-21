import 'dart:io';

import 'package:csv/csv.dart';

List<List<dynamic>> readFile(String filePath) {
  try {
    var myCsv = File(filePath);
    var csvString = myCsv.readAsStringSync();
    var converter = CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\r\n',
    );
    var data = converter.convert(csvString);
    return data;
  } catch (e) {
    print('File path not found');
  }
  return null;
}

dynamic downloadResult(String filePath, List<List<dynamic>> resultsAsList) {
  try {
    var resultData = ListToCsvConverter(
      fieldDelimiter: ',',
      eol: '\r\n',
    ).convert(resultsAsList);

    // saving file to
    // Find a location to save the file and set the path below
    var downloaded = File(filePath);
    downloaded.writeAsStringSync(resultData);
  } catch (e) {
    print('File path not found');
  }
}
