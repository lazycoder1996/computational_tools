import '../function.dart';

void loopTraverse() {
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
  stationData.removeWhere((item) => item == '');
  // initialBearing
  controls.where((element) => element == '');
  var backSightControls = controls[0].toString().split('//');
  var stationControls = controls[1].toString().split('//');
  var controlData = forwardGeodetic(
      double.parse(backSightControls[0]),
      double.parse(backSightControls[1]),
      double.parse(stationControls[0]),
      double.parse(stationControls[1]));

  // computing included angles
  var includedAngles = computeIncludedAngles(circleReadings: circleReadings);
  // compute bearings
  var unadjustedBearings = computeBearings(
      includedAngles: includedAngles, initialBearing: controlData[1]);
  print(controls);
}
