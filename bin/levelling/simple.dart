import 'dart:math' as math;

import '../function.dart';

void simpleLevelling(
    {List<List<dynamic>> levelData, String initMethod, String initAccuracy}) {
  levelData = readFile('C:/Users/muj/Desktop/MsFiles/simple_levelling.csv');
  var backSight = [];
  var benchmark = [];
  var interSight = [];
  var foreSight = [];
  int k;
  var initialReducedLevels = <num>[];
  int size;
  var heightDifferences = <num>[0];
  var dataHeadings = <String>[];
  var adj = <double>[0.0];
  var error;
  var newBackSight = [];
  String arithmeticCheck;
  num allowableMisclose;
  // ignore: unused_local_variable
  String condition;
  String misclose;
  var finalReducedLevels = <num>[];
  num nonZeroBs = 0;
  num sumOfBs = 0;
  num sumOfRise = 0;
  num sumOfFall = 0;
  num sumOfFs = 0;
  num sumOfHeights = 0;
  num diffBtnBsAndFs;
  num diffFirstRlAndLastRl;
  // ignore: omit_local_variable_types
  List<dynamic> rise = [''];
  // ignore: omit_local_variable_types
  List<dynamic> fall = [''];
  List heightCollimation;
  var errorData = <List<dynamic>>[];
  var mySwitch = false;
  var computeSwitch = true;
  bool chainagesExist;
  bool statsPressed;
  // static File myCsvFile = new File(_fileName);
  var data = <List<dynamic>>[];
  num max = 0;
  num absMax;
  num absMin;
  num min;
  num a;
  num b;
  var timesDownloaded = 0;
  var fileNames = [];
  var selectedComputation = initMethod;
  dynamic initialBmValue;
  dynamic finalBmValue;
  // putting appropriate data in columns
  for (var i = 1; i < levelData.length; i++) {
    backSight.add(levelData[i][0]);
    interSight.add(levelData[i][1]);
    foreSight.add(levelData[i][2]);
    benchmark.add(levelData[i][4]);
  }
  // getting initial bench mark
  try {
    print(benchmark.first);
    initialBmValue = benchmark.first;
    initialReducedLevels.add(num.parse(initialBmValue.toString()));
  } catch (e) {
    initialBmValue = '';
  }
  size = backSight.length;
  num h;
  var n = 0;
  num reducedLevel;
  // Calculating rise or fall
  if (initMethod == 'Rise or Fall') {
    selectedComputation = 'Rise and Fall';
    try {
      while (n <= size) {
        if (backSight[n] != '') {
          if (interSight[n + 1] != '') {
            h = backSight[n] - interSight[n + 1];
            heightDifferences.add(h);
          } else {
            h = backSight[n] - foreSight[n + 1];
            heightDifferences.add(h);
          }
        } else {
          if (interSight[n + 1] != '') {
            h = interSight[n] - interSight[n + 1];
            heightDifferences.add(h);
          } else {
            h = interSight[n] - foreSight[n + 1];
            heightDifferences.add(h);
          }
        }
        n++;
      }
    } catch (e) {
      print(heightDifferences);
      // print(e.toString());
    }
    // Calculating initial reduced levels
    n = 0;
    try {
      while (n <= size) {
        reducedLevel = initialReducedLevels[n] + heightDifferences[n + 1];
        initialReducedLevels.add(double.parse(reducedLevel.toStringAsFixed(3)));
        n++;
      }
    } catch (e) {
      // print(e.toString());
    }
    print(initialReducedLevels);
  } else {
    selectedComputation = 'Height of plane of collimation';

    // Calculating for hpc
    try {
      num hpc;
      heightCollimation = [
        backSight[0] + double.parse(initialBmValue.toString())
      ];
      initialReducedLevels = [double.parse(initialBmValue.toString())];
      n = 0;
      while (n <= size) {
        if (interSight[n + 1] != '') {
          reducedLevel = heightCollimation[n] - interSight[n + 1];
          initialReducedLevels
              .add(double.parse(reducedLevel.toStringAsFixed(3)));
          if (backSight[n + 1] != '' && foreSight[n + 1] != '') {
            hpc = initialReducedLevels[n + 1] + backSight[n + 1];
            heightCollimation.add(double.parse(hpc.toStringAsFixed(3)));
          } else {
            hpc = heightCollimation[n];
            heightCollimation.add(double.parse(hpc.toStringAsFixed(3)));
          }
        } else {
          if (foreSight[n + 1] != '') {
            reducedLevel = heightCollimation[n] - foreSight[n + 1];
            initialReducedLevels
                .add(double.parse(reducedLevel.toStringAsFixed(3)));
            if (backSight[n + 1] != '' && foreSight[n + 1] != '') {
              hpc = initialReducedLevels[n + 1] + backSight[n + 1];
              heightCollimation.add(double.parse(hpc.toStringAsFixed(3)));
            } else {
              hpc = heightCollimation[n];
              heightCollimation.add(double.parse(hpc.toStringAsFixed(3)));
            }
          }
        }
        n++;
      }
    } catch (e) {
      print(e.toString());
    }
  }
  newBackSight = backSight;
  try {
    n = 0;
    while (n <= size) {
      if (backSight[n] != '') {
        nonZeroBs++;
      }
      n++;
    }
  } catch (e) {}
  // calculating errors
  if (num.tryParse(benchmark.last.toString()) != null) {
    // nonZeroBs = 0;
    try {
      n = 0;
      error = double.parse(
          ((initialReducedLevels.last) - (num.parse(benchmark.last.toString())))
              .toStringAsFixed(3));
      print('error is $error');
      // Counting non-null values in backsight
    } catch (e) {}

    //Custom function to count non null backsights at a specified length
    num countNonZero(num n) {
      var z = 0;
      var nonZeroBackSightSpecified = 0;
      var subBackSight = [];
      subBackSight = newBackSight.sublist(0, n + 1);
      try {
        while (z <= size) {
          if (subBackSight[z] != '') {
            nonZeroBackSightSpecified++;
          }
          z++;
        }
      } catch (e) {}
      return nonZeroBackSightSpecified;
    }

    try {
      num m;
      n = 0;
      while (n <= size) {
        if (error != 0 && initialReducedLevels[n + 1] != 0) {
          m = (-error / nonZeroBs) * countNonZero(n);
          adj.add(double.parse(m.toStringAsFixed(3)));
        } else {
          m = 0;
          adj.add(double.parse(m.toStringAsFixed(3)));
        }
        n++;
      }
    } catch (e) {}
  }

  // // Calculating for final reduced levels if final Bm value is not null
  if (num.tryParse(benchmark.last.toString()) != null) {
    num frl;
    n = 0;
    try {
      while (n <= size) {
        frl = adj[n] + initialReducedLevels[n];
        finalReducedLevels.add(double.parse(frl.toStringAsFixed(3)));
        n++;
      }
    } catch (e) {
      print(e.toString());
    }
    print('frl is $finalReducedLevels');
  }
  // Arithmetic check
  try {
    // removing empty strings in foresights and backsights
    var newBacksight = [];
    n = 0;
    try {
      while (n <= size) {
        if (backSight[n] != '') {
          newBacksight.add(newBacksight[n]);
        }
        n++;
      }
    } catch (e) {}

    // Summing backsights
    try {
      int x;
      x = 0;
      while (x <= size) {
        if (newBackSight[x] != '') {
          sumOfBs = sumOfBs + newBackSight[x];
        }
        x++;
      }
    } catch (e) {} finally {
      print('sum of BS: $sumOfBs');
    }

    //Summing foresights
    try {
      var a = 0;
      while (a <= size) {
        if (foreSight[a] != '') {
          sumOfFs = sumOfFs + foreSight[a];
        }
        a++;
      }
    } catch (e) {} finally {
      print('sum of FS: $sumOfFs');
    }

    //summing rises and falls
    if (initMethod == 'Rise or Fall') {
      try {
        var b = 0;
        while (b <= size) {
          sumOfHeights = heightDifferences[b] + sumOfHeights;
          b++;
        }
      } catch (e) {} finally {
        print('sum of Rises: $sumOfHeights');
      }
    }

    sumOfFs = double.parse(sumOfFs.toStringAsFixed(3));
    diffBtnBsAndFs = sumOfBs - sumOfFs;
    diffFirstRlAndLastRl = initialReducedLevels.last - initialReducedLevels[0];
    if ((double.parse(diffBtnBsAndFs.toStringAsFixed(3)) ==
            double.parse(sumOfHeights.toStringAsFixed(3))) ||
        (double.parse(diffBtnBsAndFs.toStringAsFixed(3))) ==
            double.parse(diffFirstRlAndLastRl.toStringAsFixed(3))) {
      arithmeticCheck = 'correct';
    } else {
      arithmeticCheck = 'incorrect, please check your data';
    }
    print('arithmetic check : $arithmeticCheck');
    // Allowable
    try {
      k = int.parse(initAccuracy);
      allowableMisclose =
          double.parse((k * math.sqrt(nonZeroBs)).toStringAsFixed(3));
      if (num.tryParse(benchmark.last.toString()) != null) {
        if (error.abs() <= allowableMisclose) {
          condition = '';
          misclose = 'accepted';
        } else {
          condition = 'not ';
          misclose = 'rejected';
        }
      }
    } catch (e) {
      print(e.toString());
    }
    print('misclose is $misclose');
  } catch (e) {
    print(e.toString());
  }

  //Seperating rises and falls
  try {
    var newHeights = heightDifferences.sublist(1);
    var i;
    for (i in newHeights) {
      if (i >= 0) {
        rise.add(double.parse(i.toStringAsFixed(3)));
        fall.add('');
      } else {
        fall.add(double.parse(i.abs().toStringAsFixed(3)));
        rise.add('');
      }
    }
  } catch (e) {}
  print('rise data: $rise');
  print('fall data: $fall');

  // Removing duplicates in HPC
  try {
    n = 1;
    var x = 0;
    while (n <= size) {
      if (heightCollimation[x] == heightCollimation[n]) {
        heightCollimation[n] = '';
      } else {
        x = n;
      }
      n++;
    }
  } catch (e) {}

  //Summing rises and falls
  try {
    n = 0;
    while (n <= size) {
      if (rise[n] != '') {
        sumOfRise += rise[n];
      }
      if (fall[n] != '') {
        sumOfFall += fall[n];
      }
      n++;
    }
  } catch (e) {}

  var m = 0;

  if (initMethod == 'Rise or Fall') {
    m = 2;
  } else {
    m = 1;
  }
  // Adding results to myData
  try {
    n = 0;
    while (n < size) {
      // Adding adjustment and final reduced levels to table
      if (num.tryParse(benchmark.last.toString()) != null) {
        // Adding rise and fall columns to table
        if (initMethod == 'Rise or Fall') {
          levelData[n + 1].insert(m + 1, rise[n]);
          levelData[n + 1].insert(m + 2, fall[n]);
        }
        // Adding HPC to table
        else {
          levelData[n + 1].insert(m + 2, heightCollimation[n]);
        }
        levelData[n + 1].insert(m + 3, initialReducedLevels[n]);
        levelData[n + 1].insert(m + 4, adj[n]);
        levelData[n + 1].insert(m + 5, finalReducedLevels[n]);
      }
      // Not adding adjustment and final reduced levels to table
      else {
        // Adding rise and fall columns to table
        if (initMethod == 'Rise or Fall') {
          levelData[n + 1].insert(3, rise[n]);
          levelData[n + 1].insert(4, fall[n]);
        }
        // Adding HPC to table
        else {
          levelData[n + 1].insert(3, heightCollimation[n]);
        }
        levelData[n + 1].insert(m + 3, initialReducedLevels[n]);
      }
      n++;
    }
  } catch (e) {}

  //Appending necessary data to error Data
  errorData.add(['The selected accuracy (k)']);
  errorData[0].add(' $k');
  // errorData.add([' The selected method of computation']);
  // errorData[1].add(' $selectedComputation');
  errorData.add([' No. of stations']);
  errorData[1].add(' $nonZeroBs');
  errorData.add([' Sum of backsights']);
  errorData[2].add(' $sumOfBs');
  errorData.add([' Sum of foresights']);
  errorData[3].add(' $sumOfFs');
  errorData.add([' ΣBS - ΣFS']);
  errorData[4].add(' ' + diffBtnBsAndFs.toStringAsFixed(3));

  n = 4;
  // Rise and fall checks
  if (initMethod == 'Rise or Fall') {
    errorData.add([' Sum of rise']);
    errorData[n + 1].add(' ' + sumOfRise.toStringAsFixed(3));
    errorData.add([' Sum of fall']);
    errorData[n + 2].add(' ' + sumOfFall.toStringAsFixed(3));
    errorData.add([' Σ Rise - Σ Fall']);
    errorData[n + 3].add(' ' + sumOfHeights.toStringAsFixed(3));
    errorData.add([' Arithmetic check']);
    errorData[n + 4].add(' $arithmeticCheck');
    if (num.tryParse(benchmark.last.toString()) != null) {
      errorData.add([' The allowable misclose']);
      errorData[n + 5].add(' $allowableMisclose');
      errorData.add([' The misclose calculated']);
      errorData[n + 6].add('is $error');
    }
  }
  // HPC checks
  else {
    errorData.add([' Arithmetic check']);
    errorData[n + 1].add(' $arithmeticCheck');
    if (num.tryParse(benchmark.last.toString()) != null) {
      errorData.add([' The allowable misclose']);
      errorData[n + 2].add(' $allowableMisclose');
      errorData.add([' The misclose calculated']);
      errorData[n + 3].add(' $error');
    }
  }

  dataHeadings = [];
  dataHeadings.add('Backsight');
  dataHeadings.add('Intersight');
  dataHeadings.add('Foresight');

  if (num.tryParse(benchmark.last.toString()) != null) {
    if (initMethod == 'Rise or Fall') {
      dataHeadings.add('Rise');
      dataHeadings.add('Fall');
      dataHeadings.add('Initial Reduced Level');
      dataHeadings.add('Adjustment');
      dataHeadings.add('Final Reduced Level');
      dataHeadings.add('Remarks');
    } else {
      dataHeadings.add('Height of plane of collimation');
      dataHeadings.add('Initial Reduced Level');
      dataHeadings.add('Adjustment');
      dataHeadings.add('Final Reduced Level');
      dataHeadings.add('Remarks');
    }
  } else {
    if (initMethod == 'Rise or Fall') {
      dataHeadings.add('Rise');
      dataHeadings.add('Fall');
      dataHeadings.add('Initial Reduced Level');
      dataHeadings.add('Remarks');
    } else {
      dataHeadings.add('Height of plane of collimation');
      dataHeadings.add('Initial Reduced Level');
      dataHeadings.add('Remarks');
    }
  }
  levelData[0] = dataHeadings;
  dataHeadings.add('Controls');
  print('result is is $levelData');
  downloadResult(
      'C:/Users/muj/Desktop/MsFiles/simple_levelling_results.csv', levelData);
}
