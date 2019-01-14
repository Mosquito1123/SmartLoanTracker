import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import '../shared/loan_calculations.dart';

class LoanEmiBarChart extends StatelessWidget {
  final List<LoanCalculationSplit> loanSplits;

  List<charts.Series> _seriesList;
  final bool animate;

  LoanEmiBarChart({this.loanSplits, this.animate = true}) {
    _seriesList = buildData();
  }

  List<charts.Series<LoanCalculationSplit, String>> buildData() {
    return [
      charts.Series<LoanCalculationSplit, String>(
        id: 'Interest',
        domainFn: (LoanCalculationSplit split, _) => split.date.year.toString(),
        measureFn: (LoanCalculationSplit split, _) => split.interest,
        data: loanSplits,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      ),
      charts.Series<LoanCalculationSplit, String>(
        id: 'Principle',
        domainFn: (LoanCalculationSplit split, _) => split.date.year.toString(),
        measureFn: (LoanCalculationSplit split, _) => split.principle,
        data: loanSplits,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _seriesList,
      animate: animate,
      vertical: true,
      // Configure a stroke width to enable borders on the bars.
      defaultRenderer: charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
      behaviors: [
        charts.SeriesLegend(position: charts.BehaviorPosition.bottom),
      ],
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec:
              new charts.BasicNumericTickProviderSpec(desiredTickCount: 4),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
              (num value) => '${(value / 1000).round()}K')),
    );
  }
}
