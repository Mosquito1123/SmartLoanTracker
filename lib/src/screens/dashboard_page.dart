import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_item_splits_bloc.dart';
import '../widgets/side_drawer.dart';
import '../widgets/loan_stats_card.dart';
import '../widgets/loan_emi_card.dart';

class DashboardPage extends StatelessWidget {
  LoanItemSplitsBloc loanSplitsBloc;

  @override
  Widget build(BuildContext context) {
    LoanItemsBloc bloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      // body: LoanStatsComputedDonutChart.withSampleData(),
      body: Container(
        child: StreamBuilder(
            stream: bloc.currentLoanItem,
            builder: (BuildContext context, AsyncSnapshot<LoanItem> snapshot) {
              if (snapshot.data == null) return Text('loading...');
              loanSplitsBloc = LoanItemSplitsBloc(loanItemsBloc: bloc);
              // return LoanStatsCard(
              //   loanSplitsBloc: loanSplitsBloc,
              //   computed: true,
              // );
              return LoanEmiCard(
                loanSplitsBloc: loanSplitsBloc,
                computed: true,
              );
            }),
      ),
      drawer: SideDrawer(),
    );
  }
}

class EmiComputedStackedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  EmiComputedStackedBarChart(this.seriesList, {this.animate});

  factory EmiComputedStackedBarChart.withSampleData() {
    return EmiComputedStackedBarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      // Configure a stroke width to enable borders on the bars.
      defaultRenderer: charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.stacked, strokeWidthPx: 2.0),
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
    ];

    final tableSalesData = [
      new OrdinalSales('2014', 25),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 10),
      new OrdinalSales('2017', 20),
    ];

    final mobileSalesData = [
      new OrdinalSales('2014', 10),
      new OrdinalSales('2015', 50),
      new OrdinalSales('2016', 50),
      new OrdinalSales('2017', 45),
    ];

    return [
      // Blue bars with a lighter center color.
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      // Solid red bars. Fill color will default to the series color if no
      // fillColorFn is configured.
      charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: tableSalesData,
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
      ),
      // Hollow green bars.
      charts.Series<OrdinalSales, String>(
        id: 'Mobile',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: mobileSalesData,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.transparent,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
