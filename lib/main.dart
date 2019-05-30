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
          debugShowCheckedModeBanner: false,
          title: 'SmartLoanTracker',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            primaryColor: Color.fromARGB(255, 0, 164, 159),
            accentColor: Color.fromARGB(255, 240, 128, 66),
            fontFamily: 'Roboto',
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
