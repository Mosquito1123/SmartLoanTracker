import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../bolcs/application_bloc.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ApplicationBloc bloc = BlocProvider.of(context);
    return StreamBuilder<int>(
        stream: bloc.activeSideMenu,
        builder: (BuildContext context, AsyncSnapshot<int> menuSelection) {
          return Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Text('SmartLoanTracker'),
                ),
                ListTile(
                  selected: menuSelection.data == 1,
                  title: new Text('Dashboard'),
                  onTap: () {
                    bloc.updateSideMenuSelection(1);
                    Navigator.pop(context); //closes drawer
                    Navigator.popAndPushNamed(context, '/');
                  },
                ),
                ListTile(
                  selected: menuSelection.data == 2,
                  title: new Text('Loans List'),
                  onTap: () {
                    bloc.updateSideMenuSelection(2);
                    Navigator.pop(context); //closes drawer
                    Navigator.pushNamed(context, '/loans').then((_) {
                      bloc.updateSideMenuSelection(menuSelection.data);
                    });
                  },
                ),
              ],
            ),
          );
        });
  }
}
