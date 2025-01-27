import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../../models/quiz.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatelessWidget {
  final Quiz quiz;
  final _quizController = Get.find<QuizController>();

  QuizPage({super.key, required this.quiz}) {
    _quizController.startQuiz(quiz);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le quiz?'),
            content: const Text('Votre progression sera perdue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  _quizController.resetQuiz();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(quiz.title),
        ),
        body: Obx(() {
          if (_quizController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentQuestion = quiz.questions[_quizController.currentQuestionIndex];
          final selectedAnswer = _quizController.selectedAnswers[_quizController.currentQuestionIndex];

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_quizController.currentQuestionIndex + 1) / quiz.questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Question ${_quizController.currentQuestionIndex + 1}/${quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              // Question text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              // Choices
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: currentQuestion.choices.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<int>(
                      title: Text(currentQuestion.choices[index].text),
                      value: index,
                      groupValue: selectedAnswer,
                      onChanged: (value) {
                        if (value != null) {
                          _quizController.selectAnswer(
                            _quizController.currentQuestionIndex,
                            value,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_quizController.currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          _quizController.currentQuestionIndex--;
                        },
                        child: const Text('Précédent'),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _quizController.selectedAnswers[_quizController.currentQuestionIndex] == null
                          ? null
                          : () async {
                              if (_quizController.isLastQuestion) {
                                await _quizController.submitQuiz();
                                if (_quizController.error.isEmpty) {
                                  Get.off(() => QuizResultPage(result: _quizController.lastResult!));
                                }
                              } else {
                                _quizController.nextQuestion();
                              }
                            },
                      child: Text(_quizController.isLastQuestion ? 'Terminer' : 'Suivant'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
} 