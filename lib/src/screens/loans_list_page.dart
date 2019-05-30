import 'package:flutter/material.dart';

import 'loan_edit_page.dart';

import '../bolcs/loan_items_bloc.dart';
import '../widgets/side_drawer.dart';

class LoansListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SmartLoanTracker'),
      ),
      body: LoanList(),
      drawer: SideDrawer(),
    );
  }
}

class LoanList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoanItemsBloc bloc = BlocProvider.of(context);
    return StreamBuilder<List<LoanItem>>(
      stream: bloc.loansList,
      builder: (BuildContext context, AsyncSnapshot<List<LoanItem>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text('Loading...');
          default:
            return ListView(
              children: snapshot.data.map((LoanItem item) {
                return _buildListItem(context, bloc, item);
              }).toList(),
            );
        }
      },
    );
  }

  Widget _buildListItem(
      BuildContext context, LoanItemsBloc bloc, LoanItem item) {
    // final item = LoanItem.fromDocSnapshot(document);
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.amount.toString()),
      onTap: () {
        bloc.updateCurrentLoanItem(item);
        // Navigator.pushNamed(context, '/loan');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoanEditPage(item)),
        );
      },
    );
  }
}
