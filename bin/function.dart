import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';

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
List<dynamic> adjustBearings({List<dynamic> initialBearings}) {
  num error = initialBearings.last - initialBearings.first;
  num adjustment = error / (initialBearings.length - 1);
  var adjPerStation = <dynamic>[];
  var finalBearing = <dynamic>[];
  for (var i in initialBearings) {
    adjPerStation.add(-adjustment * initialBearings.indexOf(i));
  }
  for (var i = 0; i < adjPerStation.length; i++) {
    finalBearing.add((initialBearings[i] + adjPerStation[i]) % 360);
  }
  return [adjPerStation, finalBearing];
}

// computing lat and dep
List<List<dynamic>> computeLatDdep(
    {List<dynamic> bearings, List<dynamic> distances}) {
  var latDep = <List<dynamic>>[[], []];
  try {
    for (var i = 0; i < bearings.length; i++) {
      latDep[0].add(distances[i] * cos(converter * bearings[i + 1]));
      latDep[1].add(distances[i] * sin(converter * bearings[i + 1]));
    }
  } catch (e) {}
  return latDep;
}

// adjusting lat and dep
List<List<dynamic>> adjustLatDep(
    {String adjustmentMethod,
    List<List<dynamic>> initialLatDep,
    List<dynamic> distances}) {
  var adjLat = <dynamic>[];
  var adjDep = <dynamic>[];
  var correctedLat = <dynamic>[];
  var correctedDep = <dynamic>[];

  if (adjustmentMethod == 'Bowditch') {
    num sumLat = 0;
    num sumDistances = 0;
    num sumDep = 0;
    for (var i in initialLatDep[0]) {
      sumLat += i;
    }
    for (var i in initialLatDep[1]) {
      sumDep += i;
    }
    for (var i in distances.sublist(0, distances.length - 1)) {
      sumDistances += i;
    }
    var n = 0;
    var size = initialLatDep[0].length;
    try {
      while (n < size - 1) {
        adjLat.add((distances[n] / sumDistances) * -sumLat);
        correctedLat.add(adjLat[n] + initialLatDep[0][n]);
        adjDep.add((distances[n] / sumDistances) * -sumDep);
        correctedDep.add(adjDep[n] + initialLatDep[1][n]);
        n++;
      }
      adjLat.add(0);
      adjDep.add(0);
      correctedLat.add(initialLatDep[0].last);
      correctedDep.add(initialLatDep[1].last);
    } catch (e) {}
  } else {}
  return [adjLat, correctedLat, adjDep, correctedDep];
}

// computing northings and eastings
List<List<dynamic>> computeNorthingsEastings(
    {List<List<dynamic>> latDep, List<dynamic> controls}) {
  var results = <List<dynamic>>[
    [controls[0]],
    [controls[1]]
  ];
  try {
    for (var i = 0; i <= latDep[1].length; i++) {
      results[0].add(results[0][i] + latDep[1][i]);
      results[1].add(results[1][i] + latDep[3][i]);
    }
  } catch (e) {}
  return results;
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
  return foreBearing < 180 ? 180 + foreBearing : foreBearing - 180;
}
