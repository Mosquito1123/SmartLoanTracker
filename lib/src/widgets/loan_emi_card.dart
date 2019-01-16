import 'package:flutter/material.dart';

import '../shared/loan_calculations.dart';
import '../bolcs/loan_item_splits_bloc.dart';

import './loan_emi_bar_chart.dart';

class LoanEmiCard extends StatelessWidget {
  final bool computed;
  final LoanItemSplitsBloc loanSplitsBloc;
  final Color positiveColor, negativeColor;
  LoanEmiCard({
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
      computed ? 'Loan EMI (Computed)' : 'Loan EMI',
      style: Theme.of(context).textTheme.title,
    );
    return Card(
      child: Column(
        children: <Widget>[
          _buildTitle,
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider(color: Colors.grey[300]),
          ),
          _buildCardContent(context),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return StreamBuilder(
      stream: computed
          ? loanSplitsBloc.loanSplitsComputedByYear
          : loanSplitsBloc.loanSplitsByYear,
      builder: (BuildContext context,
          AsyncSnapshot<List<LoanCalculationSplit>> snapshot) {
        if (snapshot.data == null) return Text('loading...');

        return SizedBox(
          height: 250.0,
          // width: 200.0,
          child: LoanEmiBarChart(loanSplits: snapshot.data),
        );
      },
    );
  }
}
