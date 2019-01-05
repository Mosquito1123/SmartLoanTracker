import 'package:flutter/material.dart';

import '../bolcs/loan_items_bloc.dart';
import '../bolcs/loan_item_bloc.dart';
import '../widgets/side_drawer.dart';

class LoanEditPage extends StatefulWidget {
  final LoanItem loanItem;
  LoanEditPage(this.loanItem) {
    print('building LoanEditPage');
  }
  @override
  _LoanEditPageState createState() => _LoanEditPageState(loanItem);
}

class _LoanEditPageState extends State<LoanEditPage> {
  LoanItemBloc loanItemBloc;
  TextEditingController titleCtrl;

  final LoanItem loanItem;
  _LoanEditPageState(this.loanItem);

  @override
  void initState() {
    super.initState();
    print('state init');
    titleCtrl = TextEditingController(text: loanItem.title);
    loanItemBloc = LoanItemBloc(loanItem: loanItem);
  }

  @override
  Widget build(BuildContext context) {
    print('building LoanEditPageState');
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: _buildLoanForm(context),
      drawer: SideDrawer(),
    );
  }

  Widget _buildLoanForm(BuildContext context) {
    final Widget _buildTitleField = StreamBuilder(
      stream: loanItemBloc.title,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
          TextField(
            controller: titleCtrl,
            onChanged: loanItemBloc?.updateTitle,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: snapshot?.error,
            ),
          ),
    );
    return ListView(
      children: <Widget>[_buildTitleField],
    );
  }

  @override
  void dispose() {
    loanItemBloc.dispose();
    super.dispose();
  }
}
