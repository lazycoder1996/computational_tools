import '../function.dart';

void preciseComputation() {
  var levelData =
      readFile('C:/Users/muj/Desktop/MsFiles/precise_levelling.csv');
  var headers = levelData[0].map((e) {
    return e.toString();
  }).toList();
  // Extracting data
  var upperReading = headers.indexOf('Upper Reading');
  var middleReading = headers.indexOf('Middle Reading');
  var lowerReading = headers.indexOf('Lower Reading');
  var digitalReading = headers.indexOf('Digital Reading');
  var benchmark = headers.indexOf('Benchmark');
  // Computing X
  levelData[0].insert(5, 'X');
  for (var i in levelData.sublist(1)) {
    i.insert(
        5,
        ((double.parse(i[upperReading].toString()) +
                    double.parse(i[lowerReading].toString())) /
                2)
            .toStringAsFixed(3));
  }
  // 'bs,fs,u,m,l,x,d'
  // Computing C values
  levelData[0].add('C');
  for (var i in levelData.sublist(1)) {
    i.add(((double.parse(i[middleReading].toString()) +
                double.parse(i[5].toString()) +
                double.parse(i[digitalReading + 1].toString())) /
            3)
        .toStringAsFixed(3));
  }

  // Computing rise and fall
  levelData[0].add('Rise or Fall');
  try {
    for (var i = 1; i <= levelData.length; i = i + 2) {
      var rise =
          double.parse(levelData[i].last) - double.parse(levelData[i + 1].last);
      levelData[i + 1].add(rise.toStringAsFixed(3));
      levelData[i].add('');
    }
  } catch (d) {}

  double reducedLevel;
  levelData[1].add(double.parse(levelData[1][benchmark].toString()));
  levelData[0].add('Reduced Level');
  try {
    for (var a = 2; a <= levelData.length; a = a + 2) {
      if (a == 2) {
        levelData[a + 1].add('');
        reducedLevel = double.parse(levelData[a - 1][9].toString()) +
            double.parse(levelData[a][8].toString());
        levelData[a].add(reducedLevel.toStringAsFixed(3));
      }
      if (a % 2 == 0 && a != 2) {
        if (a != levelData.length - 1) levelData[a + 1].add('');
        reducedLevel = double.parse(levelData[a - 2][9].toString()) +
            double.parse(levelData[a][8].toString());
        levelData[a].add(reducedLevel.toStringAsFixed(3));
      }
    }
  } catch (e) {}
  downloadResult(
      'C:/Users/muj/Desktop/MsFiles/precise_levelling_result.csv', levelData);
}
