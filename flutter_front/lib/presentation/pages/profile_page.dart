import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/quiz_controller.dart';

class ProfilePage extends StatelessWidget {
  final _authController = Get.find<AuthController>();
  final _quizController = Get.find<QuizController>();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations personnelles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Nom d\'utilisateur'),
                      subtitle: Text(_authController.user?.username ?? ''),
                    )),
                    Obx(() => ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(_authController.user?.email ?? ''),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => ListTile(
                      leading: const Icon(Icons.quiz),
                      title: const Text('Quiz créés'),
                      subtitle: Text('${_quizController.quizzes.length}'),
                    )),
                    Obx(() => ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Quiz complétés'),
                      subtitle: Text('${_quizController.quizHistory.length}'),
                    )),
                    Obx(() {
                      final history = _quizController.quizHistory;
                      if (history.isEmpty) return const SizedBox.shrink();
                      
                      final totalScore = history.fold<double>(
                        0,
                        (sum, result) => sum + result.score,
                      );
                      final averageScore = (totalScore / history.length * 100).toStringAsFixed(1);
                      
                      return ListTile(
                        leading: const Icon(Icons.score),
                        title: const Text('Score moyen'),
                        subtitle: Text('$averageScore%'),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _authController.logout();
                  Get.offAllNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Déconnexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 