import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  
  // Clés pour SharedPreferences (non sécurisé, mais plus fiable sur iOS Simulator)
  static const _keyServerUrl = 'server_url';
  static const _keyApiKey = 'api_key';
  
  // Clés pour FlutterSecureStorage (sécurisé)
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyJwtToken = 'jwt_token';
  static const _keyDemoMode = 'demo_mode';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> saveServerUrl(String url) async {
    print('💾 StorageService.saveServerUrl: $url');
    final prefs = await _prefs;
    await prefs.setString(_keyServerUrl, url);
    print('✅ StorageService.saveServerUrl: sauvegardé dans SharedPreferences');
  }

  Future<String?> getServerUrl() async {
    final prefs = await _prefs;
    final value = prefs.getString(_keyServerUrl);
    print('📂 StorageService.getServerUrl: $value');
    return value;
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await _prefs;
    await prefs.setString(_keyApiKey, apiKey);
  }

  Future<String?> getApiKey() async {
    final prefs = await _prefs;
    return prefs.getString(_keyApiKey);
  }

  Future<void> saveCredentials(String email, String password) async {
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  Future<String?> getEmail() async {
    return await _secureStorage.read(key: _keyEmail);
  }

  Future<String?> getPassword() async {
    return await _secureStorage.read(key: _keyPassword);
  }

  Future<void> saveJwtToken(String token) async {
    await _secureStorage.write(key: _keyJwtToken, value: token);
  }

  Future<String?> getJwtToken() async {
    return await _secureStorage.read(key: _keyJwtToken);
  }

  Future<void> clearJwtToken() async {
    await _secureStorage.delete(key: _keyJwtToken);
  }

  Future<void> clearServerConfig() async {
    final prefs = await _prefs;
    await prefs.remove(_keyServerUrl);
    await prefs.remove(_keyApiKey);
    await _secureStorage.delete(key: _keyEmail);
    await _secureStorage.delete(key: _keyPassword);
  }

  Future<void> saveDemoMode(bool value) async {
    await _secureStorage.write(key: _keyDemoMode, value: value ? 'true' : 'false');
  }

  Future<bool> isDemoMode() async {
    final value = await _secureStorage.read(key: _keyDemoMode);
    return value == 'true';
  }

  Future<void> clearDemoMode() async {
    await _secureStorage.delete(key: _keyDemoMode);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await _prefs;
    await prefs.clear();
  }
}
