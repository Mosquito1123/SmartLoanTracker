import 'package:flutter/material.dart';

import '../bolcs/loan_amounts_bloc.dart';
import '../shared/date_formatter.dart';

class LoanAmountList extends StatelessWidget {
  LoanAmountsBloc bloc;
  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    return StreamBuilder<List<LoanAmount>>(
      stream: bloc.loanAmountsList,
      builder:
          (BuildContext context, AsyncSnapshot<List<LoanAmount>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.map((LoanAmount item) {
                return _buildListItem(context, bloc, item);
              }).toList(),
            );
        }
      },
    );
  }

  Widget _buildListItem(
      BuildContext context, LoanAmountsBloc bloc, LoanAmount item) {
    // final item = LoanItem.fromDocSnapshot(document);
    return ListTile(
      title: Text('${item.amount}'),
      subtitle: Text(DateFormatter.formatFull(item.date)),
      onTap: () {
        bloc.updateCurrentLoanAmount(item);
      },
    );
  }
}
