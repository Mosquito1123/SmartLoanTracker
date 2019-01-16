import 'package:flutter/material.dart';

import '../shared/loan_calculations.dart';
import '../bolcs/loan_item_splits_bloc.dart';

import './loan_emi_bar_chart.dart';

class LoanSplitList extends StatelessWidget {
  final bool computed;
  final LoanItemSplitsBloc loanSplitsBloc;
  final Color positiveColor, negativeColor;
  LoanSplitList({
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
      computed ? 'Loan EMI Splits (Computed)' : 'Loan EMI Splits',
      style: Theme.of(context).textTheme.title,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTitle,
            SizedBox(height: 8.0),
            Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(color: Colors.grey[800]),
            ),
            _buildCardContent(context),
          ],
        ),
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
        return Column(
          children: snapshot.data
              .map((split) => ListTile(
                    title: Text(
                      '${split.principle}',
                      style: Theme.of(context)
                          .textTheme
                          .headline
                          .copyWith(color: positiveColor),
                    ),
                    // contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                    subtitle: Text(
                      '${split.interest}',
                      style: Theme.of(context)
                          .textTheme
                          .headline
                          .copyWith(color: negativeColor),
                    ),
                    trailing: Column(
                      children: <Widget>[
                        Text(
                          '${split.finishedPercent}%',
                          style: Theme.of(context).textTheme.headline,
                        ),
                        Text(
                          '${split.date.year}',
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ],
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
