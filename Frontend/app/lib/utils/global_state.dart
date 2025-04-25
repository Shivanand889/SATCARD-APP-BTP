// lib/utils/global_state.dart
class GlobalState {
  static final GlobalState _instance = GlobalState._internal();

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();

  // Declare your global variables
  int isManager =1 ;
  String email = "" ;
  // Method to modify the global variable
  void updateGlobalVariable(int newValue) {
    isManager = newValue;
  }
  void updateGlobalVariableEmail(String newValue) {
    email = newValue;
  }
}
