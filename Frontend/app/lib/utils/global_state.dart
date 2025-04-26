import 'dart:html' as html;

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();

  int isManager = 1;
  String email = "";

  void loadFromSessionStorage() {
    email = html.window.sessionStorage['email'] ?? "";
    isManager = int.tryParse(html.window.sessionStorage['isManager'] ?? '1') ?? 1;
  }

  void updateGlobalVariable(int newValue) {
    isManager = newValue;
    html.window.sessionStorage['isManager'] = newValue.toString();
  }

  void updateGlobalVariableEmail(String newValue) {
    email = newValue;
    html.window.sessionStorage['email'] = newValue;
  }
}
