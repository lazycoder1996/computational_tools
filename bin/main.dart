import 'dart:io';

import 'package:csv/csv.dart';

import 'levelling.dart';

void main(List<String> arguments) {
  // reading file

  // NB: Please download the file from github, and set the file path below
  File myCsv = File('C:/Users/muj/Desktop/MsFiles/withCh.csv');

  // reading csv file and storing it as a string
  String csvString = myCsv.readAsStringSync();

  // initializing a converter to convert string data to a list
  CsvToListConverter converter = CsvToListConverter(
    fieldDelimiter: ',',
    eol: '\r\n',
  );

  // converting string data to a list
  List<List<dynamic>> data = converter.convert(csvString);
  print(data);
  print('1. Rise or Fall \t2. HPC');
  String initMethod = stdin.readLineSync();
  print('Enter accuracy factor, k');
  String initAccuracy = stdin.readLineSync();
  computeLevels(
      levelData: data, initAccuracy: initAccuracy, initMethod: initMethod);
}
