import '../function.dart';

void linkTraverse({String adjustBy}) {
  var traverseData = readFile('C:/Users/muj/Desktop/MsFiles/link_traverse.csv');
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
  print('final distance and bear is $finalDistBear');

  print('circle readings are $circleReadings');
  // calculating included angles
  var includedAngles = computeIncludedAngles(
    circleReadings: circleReadings,
  );
  print('included angles are $includedAngles');

  // adjust included angles
  var adjustedIncludedAngles = adjustIncludedAnglesLink(
      includedAngles: includedAngles,
      finalForwardBearing: finalDistBear[1],
      initialBackBearing: backBearing(initDistBear[1]));
  print('adjusted included angles are $adjustedIncludedAngles');
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
      adjustmentMethod: adjustBy,
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
        deg2DMS(includedAngles[n]),
        deg2DMS(adjustedIncludedAngles[0][n]),
        deg2DMS(adjustedIncludedAngles[1][n]),
        distanceData[n],
        deg2DMS(initialBearings[n]),
        (initDepLat[0][n]).toStringAsFixed(4),
        (adjustedDepLat[0][n]).toStringAsFixed(4),
        (adjustedDepLat[1][n]).toStringAsFixed(4),
        (initDepLat[1][n]).toStringAsFixed(4),
        (adjustedDepLat[2][n]).toStringAsFixed(4),
        (adjustedDepLat[3][n]).toStringAsFixed(4),
        (finalCoordinates[0].sublist(1)[n]).toStringAsFixed(4),
        (finalCoordinates[1].sublist(1)[n]).toStringAsFixed(4)
      ]);
      n++;
      m++;
    }
  } catch (e) {}
  downloadResult(
      'C:/Users/muj/Desktop/COMP_FILES/link_traverse_${adjustBy}_result.csv',
      output);
}
