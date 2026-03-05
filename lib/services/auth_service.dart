import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _dbService = DatabaseService();
  static const String SESSION_KEY = 'current_user_id';

  // ========== REGISTER ==========
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final db = await _dbService.database;

      // Check if user exists
      final existingUser = await db.query(
        'users',
        where: 'email = ? OR phone = ?',
        whereArgs: [email, phone],
      );

      if (existingUser.isNotEmpty) {
        return {
          'success': false,
          'message': 'User with this email or phone already exists',
        };
      }

      // Create user
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final user = {
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password, // In production, hash this!
        'role': role.name,
        'is_verified': 1,
        'is_active': 1,
        'created_at': now,
        'additional_info': json.encode(additionalInfo ?? {}),
      };

      await db.insert('users', user);

      return {
        'success': true,
        'message': 'Registration successful!',
        'userId': userId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // ========== LOGIN ==========
  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final db = await _dbService.database;

      // Find user by email or phone
      final users = await db.query(
        'users',
        where: '(email = ? OR phone = ?) AND password = ?',
        whereArgs: [emailOrPhone, emailOrPhone, password],
      );

      if (users.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid email/phone or password',
        };
      }

      final userData = users.first;

      // Update last login
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userData['id']],
      );

      // Create user object
      final user = User(
        id: userData['id'].toString(),
        name: userData['name'].toString(),
        email: userData['email'].toString(),
        phone: userData['phone'].toString(),
        role: UserRole.values.firstWhere(
          (r) => r.name == userData['role'].toString(),
          orElse: () => UserRole.donor,
        ),
        additionalInfo: userData['additional_info'] != null
            ? json.decode(userData['additional_info'].toString())
            : {},
      );

      // Save session
      await _saveSession(user.id);

      return {
        'success': true,
        'user': user,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // ========== SESSION MANAGEMENT ==========
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SESSION_KEY, userId);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SESSION_KEY);
  }

  Future<User?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final db = await _dbService.database;
    final users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (users.isEmpty) return null;

    final userData = users.first;
    return User(
      id: userData['id'].toString(),
      name: userData['name'].toString(),
      email: userData['email'].toString(),
      phone: userData['phone'].toString(),
      role: UserRole.values.firstWhere(
        (r) => r.name == userData['role'].toString(),
        orElse: () => UserRole.donor,
      ),
      additionalInfo: userData['additional_info'] != null
          ? json.decode(userData['additional_info'].toString())
          : {},
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SESSION_KEY);
  }
}
