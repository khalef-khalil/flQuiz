import 'package:get/get.dart';
import '../../services/api_service.dart';

class CategoryController extends GetxController {
  final _apiService = ApiService();
  final _isLoading = false.obs;
  final _error = ''.obs;
  final RxList<Map<String, dynamic>> _categories = <Map<String, dynamic>>[].obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<Map<String, dynamic>> get categories => _categories;

  int? getCategoryId(String name) {
    final category = _categories.firstWhereOrNull((cat) => cat['name'] == name);
    return category?['id'] as int?;
  }

  void setError(String message) {
    _error.value = message;
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    _error.value = '';
    _isLoading.value = true;

    try {
      final categories = await _apiService.getCategories();
      _categories.assignAll(categories);
    } catch (e) {
      _error.value = 'Échec du chargement des catégories';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createCategory(String name, {String description = ''}) async {
    if (name.isEmpty) {
      _error.value = 'Le nom de la catégorie ne peut pas être vide';
      return false;
    }

    _error.value = '';
    _isLoading.value = true;

    try {
      await _apiService.createCategory(name, description);
      await fetchCategories();
      return true;
    } catch (e) {
      _error.value = 'Échec de la création de la catégorie';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _error.value = '';
    _isLoading.value = true;

    try {
      await _apiService.deleteCategory(id);
      await fetchCategories();
      return true;
    } catch (e) {
      _error.value = 'Échec de la suppression de la catégorie';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
} 