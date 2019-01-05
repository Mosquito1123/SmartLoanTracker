import 'package:rxdart/rxdart.dart';

import './bloc_provider.dart';
export './bloc_provider.dart';

class ApplicationBloc implements BlocBase {
  BehaviorSubject<int> _activeSideMenuCtrl = BehaviorSubject<int>(seedValue: 1);

  Stream<int> get activeSideMenu => _activeSideMenuCtrl.stream;
  Function(int) get updateSideMenuSelection => _activeSideMenuCtrl.sink.add;

  @override
  void dispose() {
    _activeSideMenuCtrl.close();
  }
}
