import 'package:flutter/material.dart';

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_item_bloc.dart';
import '../bolcs/loan_amounts_bloc.dart';
import '../bolcs/loan_rois_bloc.dart';

import '../widgets/side_drawer.dart';
import '../widgets/loan_item_form.dart';
import '../widgets/loan_amount_list.dart';
import '../widgets/loan_roi_list.dart';

class LoanEditPage extends StatelessWidget {
  final LoanItem loanItem;

  LoanEditPage(this.loanItem);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loanItem.title),
          centerTitle: true,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: 'LoanData'),
              Tab(text: 'Rate of Interest'),
              Tab(text: 'Extra Amounts'),
            ],
          ),
        ),
        body: BlocProvider(
          bloc: LoanItemBloc(loanItem: loanItem),
          child: BlocProvider(
            bloc: LoanRoisBloc(loanItem: loanItem),
            child: BlocProvider(
              bloc: LoanAmountsBloc(loanItem: loanItem),
              child: TabBarView(
                children: <Widget>[
                  LoanItemForm(loanItem: loanItem),
                  LoanRoiList(),
                  LoanAmountList(),
                ],
              ),
            ),
          ),
        ),
        // drawer: SideDrawer(),
      ),
    );
  }
}
