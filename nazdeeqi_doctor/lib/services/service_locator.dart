import 'auth_service.dart';
import 'database_service.dart';

class ServiceLocator {
  static late AuthService _auth;
  static late DatabaseService _database;

  static AuthService get auth => _auth;
  static DatabaseService get database => _database;
  static bool get isDemoMode => false; // Kept for compatibility but always false

  static void init() {
    _database = FirebaseDatabaseService();
    _auth = FirebaseAuthService();
  }
}
