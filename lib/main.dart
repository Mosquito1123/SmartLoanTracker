import 'package:flutter/material.dart';

import 'src/screens/dashboard_page.dart';
import 'src/screens/loans_list_page.dart';
import 'src/screens/loan_edit_page.dart';
import './src/bolcs/loan_items_bloc.dart';
import './src/bolcs/application_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: ApplicationBloc(),
      child: BlocProvider(
        bloc: LoanItemsBloc(),
        child: MaterialApp(
          title: 'LoanTracker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // home: LoansListPage(),
          routes: {
            '/': (context) => DashboardPage(),
            '/loans': (context) => LoansListPage(),
            // '/loan': (context) => LoanEditPage(),
          },
        ),
      ),
    );
  }
}
