import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryPage extends StatelessWidget {
  final _categoryController = Get.find<CategoryController>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des catégories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add new category form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      key: const Key('categoryNameField'),
                      decoration: const InputDecoration(
                        labelText: 'Nom de la catégorie',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      key: const Key('categoryDescriptionField'),
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isEmpty) {
                          _categoryController.setError('Le nom de la catégorie ne peut pas être vide');
                          return;
                        }
                        final success = await _categoryController.createCategory(
                          _nameController.text,
                          description: _descriptionController.text,
                        );
                        if (success) {
                          _nameController.clear();
                          _descriptionController.clear();
                          _categoryController.setError('');
                        }
                      },
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Error message
            Obx(() {
              final error = _categoryController.error;
              if (error.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }),
            const SizedBox(height: 16),
            // Categories list
            Expanded(
              child: Obx(() {
                if (_categoryController.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = _categoryController.categories;
                if (categories.isEmpty) {
                  return const Center(
                    child: Text('Aucune catégorie disponible'),
                  );
                }
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      child: ListTile(
                        title: Text(category['name'] ?? ''),
                        subtitle: Text(category['description'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _categoryController.deleteCategory(
                            category['id'] as int,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
} 