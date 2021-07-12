import 'dart:math' as math;

import '../function.dart';

void linkTraverse({String adjustBy}) {
  var traverseData = readFile('C:/Users/muj/Desktop/MsFiles/linkTraverse.csv');
  var dataSize = traverseData.length;
  var backsightData = [];
  var foresightData = [];
  var stationData = [];
  var circleReadings = [];
  var distanceData = [];
  var controls = [];
  for (var i = 1; i < dataSize; i++) {
    backsightData.add(traverseData[i][0]);
    foresightData.add(traverseData[i][2]);
    stationData.add(traverseData[i][1]);
    circleReadings.add(traverseData[i][4]);
    distanceData.add(traverseData[i][5]);
    controls.add(traverseData[i][6]);
  }
  distanceData.removeWhere((element) => element == '');
  controls.removeWhere((element) => element == '');
  stationData.removeWhere((element) => element == '');
  foresightData.removeWhere((element) => element == '');
  print('station data is $stationData');
  // initial distance and bearing
  var firstControl = controls[0].toString().split(',');
  var secondControl = controls[1].toString().split(',');

  var initDistBear = forwardGeodetic(
      num.parse(firstControl[0]),
      num.parse(firstControl[1]),
      num.parse(secondControl[0]),
      num.parse(secondControl[1]));
  print('initial bearing and distance is $initDistBear');

  // ending distance and bearing
  var endFirstControl = controls[2].split(',');
  var endSecondControl = controls.last.split(',');

  var finalDistBear = forwardGeodetic(
      num.parse(endFirstControl[0]),
      num.parse(endFirstControl[1]),
      num.parse(endSecondControl[0]),
      num.parse(endSecondControl[1]));
  // calculating included angles
  var includedAngles = computeIncludedAngles(
    circleReadings: circleReadings,
  );

  // adjust included angles
  var adjustedIncludedAngles = adjustIncludedAnglesLink(
      includedAngles: includedAngles,
      finalForwardBearing: finalDistBear[1],
      initialBackBearing: backBearing(initDistBear[1]));

  // calculating initial bearings
  var initialBearings = computeBearings(
      includedAngles: adjustedIncludedAngles[1],
      initialBearing: initDistBear[1]);
  print('initial bearings are $initialBearings');
  // adjusting initial bearings
  // var adjustedBearings = adjustBearings(
  //     initialBearings: initialBearings,
  //     typeOfTraverse: 'Link',
  //     endBearing: finalDistBear[1]);

  // departure and latitudes
  var initDepLat = computeDepLat(
    bearings: initialBearings.sublist(1, initialBearings.length),
    distances: distanceData,
  );
  // print('adjusted bear are $adjustedBearings');
  print('distances are $distanceData');
  print('dep lat is $initDepLat');

  // adjust dep and lat
  var adjustedDepLat = adjustDepLat(
      adjustmentMethod: 'Transit',
      checkControls: [
        secondControl[0],
        secondControl[1],
        endFirstControl[0],
        endFirstControl[1]
      ],
      distances: distanceData,
      initialDepLat: initDepLat,
      typeOfTraverse: 'Link');
  print('adjusted dep lat are $adjustedDepLat');

  // final coordinates
  var finalCoordinates = computeEastingNorthing(
    typeOfTraverse: 'Link',
    controls: [num.parse(secondControl[0]), num.parse(secondControl[1])],
    depLat: adjustedDepLat,
  );
  print('final coordinates are $finalCoordinates');

  List<List<dynamic>> output = [];
  output.insert(0, [
    'From',
    'To',
    'Included Angle',
    'Corr to Inc. Angle',
    'Adjusted Inc. Angle',
    'Distance',
    'Bearing',
    'Departure',
    'Corr to Dep',
    'Adjusted Dep',
    'Latitude',
    'Corr to Lat',
    'Adjusted Lat',
    'Easting',
    'Northing'
  ]);
  output.insert(1, [
    '',
    stationData.first,
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    secondControl.first,
    secondControl[1]
  ]);

  var n = 0;
  var m = 1;
  try {
    while (n <= finalCoordinates[0].length) {
      output.insert(m + 1, [
        stationData[n],
        stationData[n + 1],
        includedAngles[n],
        adjustedIncludedAngles[0][n],
        adjustedIncludedAngles[1][n],
        distanceData[n],
        initialBearings[n],
        initDepLat[0][n],
        adjustedDepLat[0][n],
        adjustedDepLat[1][n],
        initDepLat[1][n],
        adjustedDepLat[2][n],
        adjustedDepLat[3][n],
        (finalCoordinates[0].sublist(1)[n]).toStringAsFixed(2),
        (finalCoordinates[1].sublist(1)[n]).toStringAsFixed(3)
      ]);
      n++;
      m++;
    }
  } catch (e) {}
  downloadResult(
      'C:/Users/muj/Desktop/MsFiles/link_traverse_result.csv', output);
}
