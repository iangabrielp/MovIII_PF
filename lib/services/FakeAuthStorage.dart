class FakeAuthStorage {
  static final Map<String, String> _userData = {};

  static void registerUser(String email, String password) {
    _userData['email'] = email;
    _userData['password'] = password;
  }

  static bool loginUser(String email, String password) {
    return _userData['email'] == email && _userData['password'] == password;
  }

  static bool isRegistered() {
    return _userData.isNotEmpty;
  }
}
