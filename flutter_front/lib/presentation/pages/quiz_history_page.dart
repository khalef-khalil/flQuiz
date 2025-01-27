import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  final _quizController = Get.find<QuizController>();

  @override
  void initState() {
    super.initState();
    print('QuizHistoryPage: initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('QuizHistoryPage: Fetching quiz history');
      _quizController.fetchQuizHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('QuizHistoryPage: build called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('QuizHistoryPage: Manual refresh triggered');
              _quizController.fetchQuizHistory();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_quizController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = _quizController.quizHistory;
        if (history.isEmpty) {
          return const Center(
            child: Text('Aucun historique disponible'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final result = history[index];
            return Card(
              child: ListTile(
                title: Text(result.quizTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Score: ${(result.score * 100).toStringAsFixed(1)}%'),
                    Text('Date: ${result.completedAt.toString().split('.')[0]}'),
                    Text('Réponses: ${result.answers.length}'),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
} 