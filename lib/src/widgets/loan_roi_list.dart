import 'package:flutter/material.dart';

import '../bolcs/loan_rois_bloc.dart';
import '../shared/date_formatter.dart';

class LoanRoiList extends StatelessWidget {
  LoanRoisBloc bloc;
  @override
  Widget build(BuildContext context) {
    bloc = BlocProvider.of(context);
    return StreamBuilder<List<LoanRoi>>(
      stream: bloc.loanRoisList,
      builder: (BuildContext context, AsyncSnapshot<List<LoanRoi>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.map((LoanRoi item) {
                return _buildListItem(context, bloc, item);
              }).toList(),
            );
        }
      },
    );
  }

  Widget _buildListItem(BuildContext context, LoanRoisBloc bloc, LoanRoi item) {
    // final item = LoanItem.fromDocSnapshot(document);
    return ListTile(
      title: Text('${item.roi}'),
      subtitle: Text(DateFormatter.formatFull(item.startDate)),
      onTap: () {
        bloc.updateCurrentLoanRoi(item);
      },
    );
  }
}
