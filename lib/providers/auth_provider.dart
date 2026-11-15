import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = AppConstants.defaultName;
  String _userEmail = AppConstants.defaultEmail;
  String _userNim = AppConstants.defaultNim;
  String _institution = AppConstants.defaultInstitution;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userNim => _userNim;
  String get institution => _institution;

  Future<void> checkAuthStatus() async {
    _isLoggedIn = await StorageService.isUserLoggedIn();
    if (_isLoggedIn) {
      _userName = await StorageService.getUserName();
      _userEmail = await StorageService.getUserEmail();
      _userNim = await StorageService.getUserNim();
      _institution = await StorageService.getUserInstitution();
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email dan kata sandi tidak boleh kosong');
    }

    if (password.trim().length < 3) {
      throw Exception('Kata sandi minimal 3 karakter');
    }

    _isLoggedIn = true;
    _userEmail = email.trim();

    if (_userEmail.toLowerCase().contains('rafi')) {
      _userName = 'Rafi Pratama';
    } else if (_userEmail.contains('@')) {
      final prefix = _userEmail.split('@').first;
      // Capitalize first letter of each part
      _userName = prefix
          .split(RegExp(r'[._-]'))
          .where((part) => part.isNotEmpty)
          .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
          .join(' ');
    } else {
      _userName = _userEmail;
    }

    await StorageService.setUserLoggedIn(
      true,
      name: _userName,
      email: _userEmail,
      nim: _userNim,
      institution: _institution,
    );
    notifyListeners();
    return true;
  }

  Future<void> loginWithGoogle() async {
    _isLoggedIn = true;
    _userName = 'Rafi Pratama';
    _userEmail = 'rafi.pratama@gmail.com';
    await StorageService.setUserLoggedIn(
      true,
      name: _userName,
      email: _userEmail,
      nim: _userNim,
      institution: _institution,
    );
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? nim,
    String? institution,
  }) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Nama, email, dan kata sandi wajib diisi');
    }

    _isLoggedIn = true;
    _userName = name.trim();
    _userEmail = email.trim();
    if (nim != null && nim.trim().isNotEmpty) _userNim = nim.trim();
    if (institution != null && institution.trim().isNotEmpty) _institution = institution.trim();

    await StorageService.setUserLoggedIn(
      true,
      name: _userName,
      email: _userEmail,
      nim: _userNim,
      institution: _institution,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await StorageService.setUserLoggedIn(false);
    notifyListeners();
  }
}
