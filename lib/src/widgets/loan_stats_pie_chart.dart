import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import '../shared/loan_calculations.dart';

class LoanStatsPieChart extends StatelessWidget {
  final LoanCalculationSplitsWithStats loanSplits;

  List<charts.Series> _seriesList;
  final bool animate;

  LoanStatsPieChart({this.loanSplits, this.animate = true}) {
    _seriesList = buildData();
  }

  List<charts.Series> buildData() {
    final data = [
      new LinearValues(0, loanSplits.stats.interestPercent, 'Interest'),
      new LinearValues(
          1,
          double.parse(
              (100 - loanSplits.stats.interestPercent).toStringAsFixed(2)),
          'Principle'),
    ];
    return [
      new charts.Series<LinearValues, int>(
        id: 'Stats',
        domainFn: (LinearValues value, _) => value.index,
        measureFn: (LinearValues value, _) => value.value,
        data: data,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (LinearValues row, _) => '${row.value}%',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart(
      _seriesList,
      animate: animate,
      defaultRenderer: new charts.ArcRendererConfig(
          arcWidth: 60,
          arcRendererDecorators: [new charts.ArcLabelDecorator()]),
    );
    // return LoanStatsComputedDonutChart.withSampleData();
  }
}

class LinearValues {
  final int index;
  final double value;
  final String legend;

  LinearValues(this.index, this.value, this.legend);
}
