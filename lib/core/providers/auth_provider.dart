import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthMethod {
  email,
  google,
  github,
  apple,
}

class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final AuthMethod authMethod;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.authMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'auth_method': authMethod.index,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      authMethod: AuthMethod.values[json['auth_method']],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  get displayName => null;
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        // Parse user data (simplified - في الواقع نحتاج JSON library)
        // _currentUser = User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      _error = 'خطأ في تحميل بيانات المستخدم';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate authentication
      await Future.delayed(const Duration(seconds: 2));
      
      // في التطبيق الحقيقي، هنا نستخدم Firebase Auth
      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: 'demo_user',
          email: email,
          name: 'مستخدم تجريبي',
          authMethod: AuthMethod.email,
          createdAt: DateTime.now(),
        );
        
        await _saveUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate registration
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        authMethod: AuthMethod.email,
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء إنشاء الحساب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // في التطبيق الحقيقي، نستخدم Google Sign In
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: 'google_user',
        email: 'user@gmail.com',
        name: 'مستخدم Google',
        authMethod: AuthMethod.google,
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول بـ Google';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGitHub() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // في التطبيق الحقيقي، نستخدم GitHub OAuth
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: 'github_user',
        email: 'user@github.com',
        name: 'مستخدم GitHub',
        authMethod: AuthMethod.github,
        createdAt: DateTime.now(),
      );
      
      await _saveUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء تسجيل الدخول بـ GitHub';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      // في التطبيق الحقيقي، نستخدم jsonEncode
      await prefs.setString('current_user', _currentUser!.email);
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      // حذف بيانات المستخدم من Firebase أو قاعدة البيانات
      await Future.delayed(const Duration(seconds: 2));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء حذف الحساب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // إرسال إيميل إعادة تعيين كلمة المرور
      await Future.delayed(const Duration(seconds: 2));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'حدث خطأ أثناء إرسال رابط إعادة التعيين';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
