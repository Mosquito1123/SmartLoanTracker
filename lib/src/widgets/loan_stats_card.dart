import 'package:flutter/material.dart';

import '../shared/loan_calculations.dart';
import '../bolcs/loan_item_splits_bloc.dart';

import './loan_stats_pie_chart.dart';

class LoanStatsCard extends StatelessWidget {
  final bool computed;
  final LoanItemSplitsBloc loanSplitsBloc;
  final Color positiveColor, negativeColor;
  LoanStatsCard({
    this.computed = false,
    this.loanSplitsBloc,
    this.positiveColor = Colors.green,
    this.negativeColor = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    Widget _buildTitle = Text(
      computed ? 'Loan Stats (Computed)' : 'Loan Stats',
      style: Theme.of(context).textTheme.title,
    );
    return Card(
      child: Column(
        children: <Widget>[
          _buildTitle,
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider(color: Colors.grey[400]),
          ),
          _buildCardContent(context),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return StreamBuilder(
      stream: computed
          ? loanSplitsBloc.loansComputedCalculations
          : loanSplitsBloc.loansCalculations,
      builder: (BuildContext context,
          AsyncSnapshot<LoanCalculationSplitsWithStats> snapshot) {
        if (snapshot.data == null) return Text('loading...');

        return _buildStats(context, snapshot.data);
      },
    );
  }

  Column _buildStatHeaderNumbers(Color color, String number, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          number,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
      BuildContext context, LoanCalculationSplitsWithStats stats) {
    Widget _buildStatHeader = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildStatHeaderNumbers(
          negativeColor,
          stats.stats.interest.toStringAsFixed(0),
          'INTEREST',
        ),
        _buildStatHeaderNumbers(
          positiveColor,
          stats.stats.total.toStringAsFixed(0),
          'TOTAL',
        ),
      ],
    );
    Widget _buildStatChart = SizedBox(
      height: 250.0,
      // width: 200.0,
      child: LoanStatsPieChart(
        loanSplits: stats,
        positiveColor: positiveColor,
        negativeColor: negativeColor,
      ),
    );

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[_buildStatHeader, _buildStatChart],
      ),
    );
  }
}
