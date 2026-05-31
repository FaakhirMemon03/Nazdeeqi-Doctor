import 'auth_service.dart';
import 'database_service.dart';

class ServiceLocator {
  static late AuthService _auth;
  static late DatabaseService _database;
  static bool _isDemo = true;

  static AuthService get auth => _auth;
  static DatabaseService get database => _database;
  static bool get isDemoMode => _isDemo;

  static void init({required bool demoMode}) {
    _isDemo = demoMode;
    if (demoMode) {
      _database = MockDatabaseService();
      _auth = MockAuthService();
    } else {
      _database = FirebaseDatabaseService();
      _auth = FirebaseAuthService();
    }
  }
}
