import 'dart:io';
import 'dart:math';
import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';

// creating zip
void createZip() {
  final logDir = 'C:/Users/muj/Desktop/MsFiles/log';
  final zipLocation = 'C:/Users/muj/Desktop/MsFiles/log.zip';

  var encoder = ZipFileEncoder();
  encoder.zipDirectory(Directory(logDir), filename: zipLocation);

  // Manually create a zip of a directory and individual files.
  encoder.create('C:/Users/muj/Desktop/MsFiles/log.zip');
  encoder.addFile(
      File('C:/Users/muj/Desktop/MsFiles/simple_levelling_results.csv'));

  encoder.close();
}

// reading file
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

// downloading results
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

num converter = (pi / 180);
// computing included angles
List computeIncludedAngles({List<dynamic> circleReadings}) {
  var doubleIncludedAngles = <dynamic>[];
  var includedAngles = <dynamic>[];
  circleReadings.insert(0, 0);
  var n = 2;
  num angle;
  var size = circleReadings.length;
  // double included angles
  try {
    while (n < size) {
      if (n % 2 == 0 && n % 4 != 0) {
        angle = (circleReadings[n] - circleReadings[n - 1]) % 360;
      } else if (n % 2 == 0 && n % 4 == 0) {
        angle = (circleReadings[n - 1] - circleReadings[n]) % 360;
      }
      doubleIncludedAngles.add(angle);
      n += 2;
    }
    // ignore: empty_catches
  } catch (e) {}
  n = 0;
  num meanAngle;
  try {
    while (n < doubleIncludedAngles.length) {
      meanAngle = doubleIncludedAngles[n] + doubleIncludedAngles[n + 1];
      includedAngles.add(meanAngle / 2);
      n += 2;
    }
    // ignore: empty_catches
  } catch (e) {}
  return includedAngles;
}

num computeExpectedAngles(num sides, direction) {
  if (direction == 'clockwise') {
    return (sides + 2) * 180;
  } else if (direction == 'anticlockwise') {
    return (sides - 2) * 180;
  }
  return null;
}

num sumItemsInList(List<dynamic> items) {
  num sum = 0;
  for (var i in items) {
    sum += i;
  }
  return sum;
}

num whichToUse(num initialBearing, num endBearing) {
  if (endBearing - initialBearing > endBearing - 360) {
    return endBearing - 360;
  }
}

// adjust included angles
List<List<dynamic>> adjustIncludedAnglesLink(
    {List<dynamic> includedAngles,
    num finalForwardBearing,
    num initialBackBearing}) {
  num sumAngles = 0;
  for (num i in includedAngles) {
    sumAngles += i;
  }
  num size = includedAngles.length;
  var expectedSumAngles = [];
  for (var i = size - 1; i <= size + 1; i++) {
    expectedSumAngles.add(
        (sumAngles - ((finalForwardBearing - initialBackBearing) + (i * 180)))
            .abs());
  }
  var m = minimum(expectedSumAngles);
  var finalM = expectedSumAngles.indexOf(m) + size - 1;
  var expectedSum = (finalForwardBearing - initialBackBearing) + (finalM * 180);
  var error = sumAngles - expectedSum;
  var adjPerStation = -error / size;
  var adjustment = [[], []];
  for (var i in includedAngles) {
    adjustment[0].add(adjPerStation);
    adjustment[1].add(adjPerStation + i);
  }
  return adjustment;
}

num minimum(List numbers) {
  num result = numbers[0];
  num n = 1;
  try {
    while (n <= numbers.length) {
      if (numbers[n] <= result) {
        result = numbers[n];
      }
      n++;
    }
  } catch (e) {}
  return result;
}

// adjust included angles
List<List<dynamic>> adjustIncludedAngles(
    {List<dynamic> includedAngles, String direction}) {
  var results = <List<dynamic>>[[], []];
  var size = includedAngles.length;
  var n = 0;
  var observedAngles = sumItemsInList(includedAngles);
  var expectedAngles = computeExpectedAngles(size, direction);
  var error = observedAngles - expectedAngles;
  var adjPerStation = -error / size;
  try {
    while (n <= size) {
      results[0].add(adjPerStation);
      results[1].add(results[0][n] + includedAngles[n]);
      n++;
    }
  } catch (e) {}
  return results;
}

// computing bearings
List<dynamic> computeBearings(
    {num initialBearing, List<dynamic> includedAngles}) {
  var results = <dynamic>[initialBearing];
  var size = includedAngles.length;
  var n = 0;
  try {
    while (n <= size) {
      results.add((backBearing(results[n]) + includedAngles[n]) % 360);
      n++;
    }
    // ignore: empty_catches
  } catch (e) {}
  return results;
}

// adjusting bearings
List<dynamic> adjustBearings(
    {List<dynamic> initialBearings, String typeOfTraverse, num endBearing}) {
  num error = 0;
  if (typeOfTraverse == null) {
    error = initialBearings.last - initialBearings.first;
    if (initialBearings.first >= 0 && initialBearings.first < 1) {
      error = whichToUse(initialBearings.first, initialBearings.last);
    }
  } else {
    error = initialBearings.last - endBearing;
  }
  num adjustment = 0;
  if (typeOfTraverse == null) {
    adjustment = error / (initialBearings.length - 1);
  } else {
    adjustment = error / initialBearings.length;
  }
  var adjPerStation = <dynamic>[];
  var finalBearing = <dynamic>[];
  for (var i in initialBearings) {
    adjPerStation.add(-1 * adjustment * initialBearings.indexOf(i));
  }
  for (var i = 0; i < adjPerStation.length; i++) {
    finalBearing.add((initialBearings[i] + adjPerStation[i]) % 360);
  }
  return [adjPerStation, finalBearing];
}

// computing lat and dep
List<List<dynamic>> computeDepLat(
    {List<dynamic> bearings, List<dynamic> distances}) {
  var depLat = <List<num>>[[], []];
  try {
    for (var i = 0; i <= bearings.length; i++) {
      depLat[0].add(num.parse(distances[i].toString()) *
          sin(converter * num.parse(bearings[i].toString())));
      depLat[1].add(num.parse(distances[i].toString()) *
          cos(converter * num.parse(bearings[i].toString())));
    }
  } catch (e) {}
  return depLat;
}

List<List<dynamic>> adjustDepLatLink(
    {List<dynamic> checkControls,
    String adjustmentMethod,
    List<List<dynamic>> initialDepLat,
    List<List<dynamic>> distances}) {
  num sumDep = 0;
  num sumLat = 0;
  for (var i in initialDepLat[0]) {
    sumDep += i;
  }
  for (var i in initialDepLat[1]) {
    sumLat += i;
  }
  if (adjustmentMethod == 'Transit') {
    num absSumDep = 0;
    num absSumLat = 0;
    for (num i in initialDepLat[0]) {
      absSumDep += i.abs();
    }
    for (num i in initialDepLat[1]) {
      absSumLat += i.abs();
    }
  }
}

// adjusting lat and dep for loop
List<List<dynamic>> adjustDepLat(
    {String adjustmentMethod,
    List<List<dynamic>> initialDepLat,
    List<dynamic> checkControls,
    String typeOfTraverse,
    List<dynamic> distances}) {
  var adjLat = typeOfTraverse != null ? [] : <dynamic>[''];
  var adjDep = typeOfTraverse != null ? [] : <dynamic>[''];
  var correctedLat = typeOfTraverse != null ? [] : <dynamic>[''];
  var correctedDep = typeOfTraverse != null ? [] : <dynamic>[''];
  num sumLat = 0;
  num sumDistances = 0;
  num sumDep = 0;
  for (var i in (typeOfTraverse != null
      ? initialDepLat[1]
      : initialDepLat[1].sublist(1))) {
    sumLat += i;
  }
  for (var i in (typeOfTraverse != null
      ? initialDepLat[0]
      : initialDepLat[0].sublist(1))) {
    sumDep += i;
  }
  for (var i in (typeOfTraverse != null
      ? distances
      : distances.sublist(1, distances.length - 1))) {
    sumDistances += i;
  }

  print('sum dep is $sumDep');
  print('sum lat is $sumLat');
  num absoluteSumDep = 0;
  num absoluteSumLat = 0;
  num errorInDep = 0;
  num errorInLat = 0;
  if (adjustmentMethod == 'Transit') {
    if (typeOfTraverse == 'Link') {
      var expectedSumDep =
          num.parse(checkControls[2]) - num.parse(checkControls[0]);
      var expectedSumLat =
          num.parse(checkControls[3]) - num.parse(checkControls[1]);
      errorInDep = sumDep - expectedSumDep;
      errorInLat = sumLat - expectedSumLat;
    }
    for (num i in (typeOfTraverse != null
        ? initialDepLat[0]
        : initialDepLat[0].sublist(1))) {
      absoluteSumDep += i.abs();
    }
    print('absolute sum dep is $absoluteSumDep');
    for (num i in (typeOfTraverse != null
        ? initialDepLat[1]
        : initialDepLat[1].sublist(1))) {
      absoluteSumLat += i.abs();
    }
    print('absolute sum lat is $absoluteSumLat');
    var n = typeOfTraverse != null ? 0 : 1;
    var size = initialDepLat[0].length;
    try {
      while (typeOfTraverse != null ? (n < size) : (n < size - 1)) {
        adjDep.add(((typeOfTraverse == 'Link' ? -errorInDep : -sumDep) *
                initialDepLat[0][n].abs()) /
            absoluteSumDep);
        correctedDep.add(adjDep[n] + initialDepLat[0][n]);
        adjLat.add(((typeOfTraverse == 'Link' ? -errorInLat : -sumLat) *
                initialDepLat[1][n].abs()) /
            absoluteSumLat);
        correctedLat.add(adjLat[n] + initialDepLat[1][n]);
        n++;
      }
    } catch (e) {}
  } else if (adjustmentMethod == 'Bowditch') {
    // print(distances);
    // print('sum dist is $sumDistances');
    // print('sum dep is $sumDep');
    // print('sum lat is $sumLat');
    if (typeOfTraverse == 'Link') {
      var expectedSumDep =
          num.parse(checkControls[2]) - num.parse(checkControls[0]);
      var expectedSumLat =
          num.parse(checkControls[3]) - num.parse(checkControls[1]);
      errorInDep = sumDep - expectedSumDep;
      errorInLat = sumLat - expectedSumLat;
    }

    var n = typeOfTraverse != null ? 0 : 1;
    var size = distances.length;
    // try {
    while (typeOfTraverse != null ? (n < size) : (n < size - 1)) {
      adjDep.add((typeOfTraverse != null ? -errorInDep : -sumDep) *
          (distances[n] / sumDistances));
      correctedDep.add(adjDep[n] + initialDepLat[0][n]);
      adjLat.add((typeOfTraverse != null ? -errorInLat : -sumLat) *
          ((distances[n] / sumDistances)));
      correctedLat.add(adjLat[n] + initialDepLat[1][n]);
      n++;
    }
    // } catch (e) {
    //   print(e.toString());
    // }
    if (typeOfTraverse == null) {
      adjLat.add(0);
      adjDep.add(0);
      correctedDep.add(initialDepLat[0].last);
      correctedLat.add(initialDepLat[1].last);
    }
  } else {}

// linear misclose and fractional misclose
  var linearMisclose = sqrt(
      pow(typeOfTraverse != null ? errorInDep : sumDep, 2) +
          pow(typeOfTraverse != null ? errorInLat : sumLat, 2));
  var fractionalMisclose = typeOfTraverse != null
      ? (sumDistances) / linearMisclose
      : (sumDistances + distances.first) / linearMisclose;
  var fracMisclose = '1 in ${fractionalMisclose.round()}';
  print('fractional misclose is $fracMisclose');
  print('linear misclose is ${linearMisclose.toStringAsFixed(4)}');
  return [adjDep, correctedDep, adjLat, correctedLat];
}
// print()

// computing northings and eastings
List<List<dynamic>> computeEastingNorthing(
    {List<List<dynamic>> depLat,
    List<dynamic> controls,
    String typeOfTraverse}) {
  var eastingNorthing = <List<dynamic>>[
    [controls[0]],
    [controls[1]]
  ];
  try {
    for (var i = typeOfTraverse == 'Link' ? 0 : 1; i <= depLat[1].length; i++) {
      eastingNorthing[0].add(eastingNorthing[0]
              [typeOfTraverse == 'Link' ? i : i - 1] +
          depLat[1][i]);
      eastingNorthing[1].add(eastingNorthing[1]
              [typeOfTraverse == 'Link' ? i : i - 1] +
          depLat[3][i]);
    }
  } catch (e) {}
  return eastingNorthing;
}

// need functions
List forwardGeodetic(
    num eastingsOne, num northingsOne, num eastingsTwo, num northingsTwo) {
  num inverseTan = (180 / pi);
  var changeInEastings = eastingsTwo - eastingsOne;
  var changeInNorthings = northingsTwo - northingsOne;
  num bearing;
  num length = sqrt((pow(changeInEastings, 2) + pow(changeInNorthings, 2)));
  try {
    bearing = atan(changeInEastings / changeInNorthings) * inverseTan;
  } catch (e) {}
  if (changeInNorthings > 0 && changeInEastings > 0) {
    bearing = bearing;
  } else if (changeInNorthings < 0 && changeInEastings < 0) {
    bearing += 180;
  } else if (changeInNorthings > 0 && changeInEastings < 0) {
    bearing += 360;
  } else if (changeInNorthings < 0 && changeInEastings > 0) {
    bearing += 180;
  } else if (changeInEastings == 0 && changeInNorthings > 0) {
    bearing = 0;
  } else if (changeInEastings == 0 && changeInNorthings < 0) {
    bearing = 180;
  } else if (changeInEastings > 0 && changeInNorthings == 0) {
    bearing = 90;
  } else if (changeInEastings < 0 && changeInNorthings == 0) {
    bearing = 270;
  }
  return [length, bearing];
}

num backBearing(num foreBearing) {
  return foreBearing <= 180 ? 180 + foreBearing : foreBearing - 180;
}

num sumItems(list) {
  num sum;
  for (var i in list) {
    sum += i;
  }
  return sum;
}

String deg2DMS(myNumber) {
  String sign;
  num a = myNumber.abs();
  var degrees = a.truncate();
  var b = (a - degrees) * 60;
  var minutes = b.truncate();
  var c = b - minutes;
  var seconds = num.parse((c * 60).toStringAsFixed(2));
  if (seconds >= 60) {
    minutes++;
    seconds = 60 - seconds;
  }
  if (minutes >= 60) {
    degrees++;
    minutes = 60 - minutes;
  }
  if (myNumber.isNegative == true) {
    sign = '-';
  } else {
    sign = '';
  }
  var degreesStandard = degrees.toString();
  var minutesStandard = minutes.toString();
  var sec = seconds.toString();
  var endSec = sec.substring(sec.indexOf('.') + 1);
  var secondsStandard = sec.substring(0, sec.indexOf('.'));
  if (degreesStandard.length == 1) {
    degreesStandard = '00' + degreesStandard;
  } else if (degreesStandard.length == 2) {
    degreesStandard = '0' + degreesStandard;
  } else {
    degreesStandard = degreesStandard;
  }
  if (minutesStandard.length == 1) {
    minutesStandard = '0' + minutesStandard;
  } else {
    minutesStandard = minutesStandard;
  }
  if (secondsStandard.length == 1) {
    secondsStandard = '0' + secondsStandard;
  } else {
    secondsStandard = secondsStandard;
  }
  if (endSec.length == 1) {
    endSec = endSec + '0';
  }
  // else if (endSec.length == 2) {
  //   endSec = endSec + '00';
  // } else if (endSec.length == 3) {
  //   endSec = endSec + '0';
  // } else {
  //   endSec = endSec;
  // }
  return sign +
      degreesStandard +
      ' ' +
      minutesStandard +
      ' ' +
      secondsStandard +
      '.' +
      endSec;
}

num dms2Deg(String dms) {
  var dmsString = dms.toString();
  num a = dmsString.indexOf('°');
  var degrees = num.parse(dmsString.substring(0, a));
  num b = dmsString.indexOf("'");
  var minutes = num.parse(dmsString.substring(a + 1, b));
  var seconds = num.parse(dmsString.substring(b + 1, dmsString.length - 1));
  var answer = degrees + (minutes / 60) + (seconds / 3600);
  return answer;
}
