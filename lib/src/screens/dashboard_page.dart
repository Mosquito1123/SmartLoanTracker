import 'package:flutter/material.dart';

import '../bolcs/loan_items_bloc.dart';
import '../widgets/side_drawer.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Text('Dashboard Content'),
      drawer: SideDrawer(),
    );
  }
}
