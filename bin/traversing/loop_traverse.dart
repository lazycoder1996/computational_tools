import '../function.dart';

void loopTraverse({String adjustBy}) {
  var traverseData = readFile('C:/Users/muj/Desktop/MsFiles/loop_traverse.csv');
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
  // print('backsight data $backsightData');
  // print('foresight data $foresightData');
  stationData.removeWhere((element) => element == '');
  // print('station data is $stationData');
  stationData.insert(0, stationData.last);
  stationData.add(stationData[1]);
  // initialBearing
  controls.removeWhere((element) => element == '');
  var backSightControls = controls[0].toString().split(',');
  var stationControls = controls[1].toString().split(',');
  var controlData = forwardGeodetic(
      double.parse(backSightControls[0]),
      double.parse(backSightControls[1]),
      double.parse(stationControls[0]),
      double.parse(stationControls[1]));
  // adding distance of controls to distanceData
  distanceData.insert(0, controlData[0]);
  distanceData.add(controlData[0]);
  distanceData.removeWhere((element) => element == '');
  // print('distance data are $distanceData');
  // computing included angles
  var includedAngles = computeIncludedAngles(circleReadings: circleReadings);
  num sum = 0;
  includedAngles.forEach((element) {
    sum += element;
  });
  // print(includedAngles);
  // print(sum);
  // adjusted included angles
  // var adjustedIncludedAngles = adjustIncludedAngles(
  //     includedAngles: includedAngles, direction: direction);
  // print('adjusted included angles are $adjustedIncludedAngles');
  // compute bearings
  var unadjustedBearings = computeBearings(
      includedAngles: includedAngles, initialBearing: controlData[1]);
  // print('initial bearing is ${controlData[1]}');
  // print('initial bearings are $unadjustedBearings');
  // adjust bearings
  var adjustedBearings = adjustBearings(initialBearings: unadjustedBearings);
  // print('adjusted bearings are $adjustedBearings');
  // compute dep and lat
  var depLat =
      computeDepLat(bearings: adjustedBearings[1], distances: distanceData);
  // print('dep and lat are $depLat');
  // adjust dep lat
  var adjustedDepLat = adjustDepLat(
    adjustmentMethod: adjustBy,
    distances: distanceData,
    initialDepLat: depLat,
  );
  // print('adjusted dep lat are $adjustedDepLat');
  // computing eastings and northings
  var finalCoordinates = computeEastingNorthing(
      controls: [num.parse(stationControls[0]), num.parse(stationControls[1])],
      depLat: adjustedDepLat);
  print('final coordinates are $finalCoordinates');
  finalCoordinates.forEach((element) {
    print(element.toString());
  });
  List<List<dynamic>> output = [];
  output.insert(0, [
    'From',
    'To',
    'Included Angle',
    'Distance',
    'Bearing',
    'Corr to Bear',
    'Adjusted Bear',
    'Departure',
    'Corr to Dep',
    'Adjusted Dep',
    'Latitude',
    'Corr to Lat',
    'Adjusted Lat',
    'Easting',
    'Northing'
  ]);
  includedAngles.insert(0, '');
  var n = 0;
  try {
    while (n <= finalCoordinates[0].length) {
      output.insert(n + 1, [
        stationData[n],
        stationData[n + 1],
        includedAngles[n],
        distanceData[n],
        unadjustedBearings[n],
        adjustedBearings[0][n],
        adjustedBearings[1][n],
        depLat[0][n],
        adjustedDepLat[0][n],
        adjustedDepLat[1][n],
        depLat[1][n],
        adjustedDepLat[2][n],
        adjustedDepLat[3][n],
        finalCoordinates[0][n],
        finalCoordinates[1][n]
      ]);
      n++;
    }
  } catch (e) {}
  downloadResult(
      'C:/Users/muj/Desktop/COMP_FILES/loop_traverse_${adjustBy}_result.csv',
      output);
}
