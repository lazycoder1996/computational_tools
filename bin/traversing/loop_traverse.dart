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
  var headers = traverseData.sublist(0);
  for (var i = 1; i < dataSize; i++) {
    backsightData.add(headers[0]);
    foresightData.add(headers[2]);
    stationData.add(headers[1]);
    circleReadings.add(headers[4]);
    distanceData.add(headers[5]);
    controls.add(headers[6]);
  }
  stationData.removeWhere((item) => item == '');
  print(traverseData);
}
