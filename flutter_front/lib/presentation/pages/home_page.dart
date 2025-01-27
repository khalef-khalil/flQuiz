import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/category_controller.dart';
import '../../models/quiz.dart';

class HomePage extends StatelessWidget {
  final _quizController = Get.find<QuizController>();
  final _authController = Get.find<AuthController>();
  final _categoryController = Get.find<CategoryController>();

  HomePage({super.key});

  Future<void> _confirmDelete(BuildContext context, Quiz quiz) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer le quiz "${quiz.title}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _quizController.deleteQuiz(quiz.id);
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher un quiz',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _quizController.setSearchQuery,
            ),
            const SizedBox(height: 16),
            // Difficulty filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Difficulté',
                border: OutlineInputBorder(),
              ),
              value: _quizController.selectedDifficulty,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Toutes les difficultés'),
                ),
                ..._quizController.difficulties.map((diff) => DropdownMenuItem(
                  value: diff['value'],
                  child: Text(diff['label']!),
                )),
              ],
              onChanged: _quizController.setSelectedDifficulty,
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            // Category filter
            Obx(() {
              final categories = _categoryController.categories;
              return DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                value: _quizController.selectedCategory,
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Toutes les catégories'),
                  ),
                  ...categories.map((cat) {
                    final value = cat['id'] as int?;
                    final label = cat['name'] as String?;
                    if (value == null || label == null) return null;
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(label),
                    );
                  }).whereType<DropdownMenuItem<int>>(),
                ],
                onChanged: _quizController.setSelectedCategory,
                isExpanded: true,
              );
            }),
            const SizedBox(height: 16),
            // Clear filters button
            Center(
              child: TextButton.icon(
                onPressed: _quizController.clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _authController.logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Obx(() => Text(
                'Bienvenue, ${_authController.user?.username ?? ""}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              )),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Get.back();
                Get.toNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Catégories'),
              onTap: () {
                Get.back();
                Get.toNamed('/categories');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historique'),
              onTap: () {
                Get.back();
                Get.toNamed('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Get.back();
                _authController.logout();
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_quizController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_quizController.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _quizController.error,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _quizController.fetchQuizzes,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFilterSection(),
            ),
            Expanded(
              child: _quizController.quizzes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Aucun quiz disponible'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Get.toNamed('/create-quiz'),
                          child: const Text('Créer un quiz'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _quizController.fetchQuizzes,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _quizController.quizzes.length,
                      itemBuilder: (context, index) {
                        final quiz = _quizController.quizzes[index];
                        return Card(
                          child: ListTile(
                            title: Text(quiz.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(quiz.description),
                                const SizedBox(height: 4),
                                Text(
                                  'Catégorie: ${quiz.categoryName ?? "Non catégorisé"}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Chip(
                                  label: Text(quiz.difficultyLabel),
                                  backgroundColor: _getDifficultyColor(quiz.difficulty),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(context, quiz),
                                ),
                              ],
                            ),
                            onTap: () => Get.toNamed('/quiz/${quiz.id}'),
                          ),
                        );
                      },
                    ),
                  ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-quiz'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facile':
        return Colors.green.shade100;
      case 'moyen':
        return Colors.orange.shade100;
      case 'difficile':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
} 