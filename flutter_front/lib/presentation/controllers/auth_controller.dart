import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class AuthController extends GetxController {
  final _apiService = ApiService();
  final _isLoading = false.obs;
  final _error = ''.obs;
  final Rxn<User> _user = Rxn<User>();
  final _storage = GetStorage();

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  User? get user => _user.value;
  bool get isLoggedIn => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    ever(_error, (_) {
      if (_error.value.isNotEmpty) {
        Get.snackbar(
          'Erreur',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    });
    ever(_user, (user) {
      if (user == null) {
        _storage.remove('token');
        _storage.remove('user');
      }
    });
    checkAuthStatus();
  }

  void checkAuthStatus() {
    try {
      final token = _storage.read('token');
      final userData = _storage.read('user');
      
      if (token != null && userData != null) {
        _user.value = User.fromJson(userData);
      } else {
        _user.value = null;
      }
    } catch (e) {
      _user.value = null;
      _error.value = 'Error checking auth status';
    }
  }

  Future<void> login(String username, String password) async {
    _error.value = '';
    _isLoading.value = true;

    try {
      final response = await _apiService.login(username, password);
      _storage.write('token', response['token']);
      _storage.write('user', response['user']);
      _user.value = User.fromJson(response['user']);
      Get.offAllNamed('/');
    } catch (e) {
      _error.value = 'Échec de la connexion';
      _user.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password) async {
    _error.value = '';
    _isLoading.value = true;

    try {
      final response = await _apiService.register(username, email, password);
      _storage.write('token', response['token']);
      _storage.write('user', response['user']);
      _user.value = User.fromJson(response['user']);
      Get.offAllNamed('/');
    } catch (e) {
      _error.value = 'Échec de l\'inscription';
      _user.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  void logout() {
    try {
      _apiService.logout();
    } finally {
      _user.value = null;
      Get.offAllNamed('/login');
    }
  }
} 