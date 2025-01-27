import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../../models/quiz.dart';
import 'quiz_page.dart';

class QuizDetailsPage extends StatelessWidget {
  final Quiz quiz;
  final _quizController = Get.find<QuizController>();

  QuizDetailsPage({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
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
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(quiz.description),
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
                    Text(
                      'Détails',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('Temps limite'),
                      subtitle: Text('${quiz.timeLimit} minutes'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Catégorie'),
                      subtitle: Text(quiz.categoryName ?? 'Non catégorisé'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Difficulté'),
                      subtitle: Text(quiz.difficultyLabel),
                      trailing: Chip(
                        label: Text(quiz.difficultyLabel),
                        backgroundColor: _getDifficultyColor(quiz.difficulty),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.question_answer),
                      title: const Text('Questions'),
                      subtitle: Text('${quiz.questions.length} questions'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quiz.questions.isEmpty
                    ? null
                    : () => Get.to(() => QuizPage(quiz: quiz)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Commencer'),
              ),
            ),
          ],
        ),
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