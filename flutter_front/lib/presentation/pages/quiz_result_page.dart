import 'package:flutter/material.dart';
import '../../models/quiz_result.dart';
import '../../models/quiz.dart';

class QuizResultPage extends StatelessWidget {
  final QuizResult result;

  const QuizResultPage({super.key, required this.result});

  Widget _buildAnswerDetails(BuildContext context, Question question, String selectedChoiceId) {
    final selectedChoice = question.choices.firstWhere(
      (c) => c.id.toString() == selectedChoiceId,
      orElse: () => Choice(id: -1, text: 'Non trouvé', isCorrect: false),
    );
    final correctChoice = question.choices.firstWhere((c) => c.isCorrect);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${question.order + 1}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              question.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedChoice.isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedChoice.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Votre réponse: ', 
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Text(
                          selectedChoice.text,
                          style: TextStyle(
                            color: selectedChoice.isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        selectedChoice.isCorrect ? Icons.check_circle : Icons.cancel,
                        color: selectedChoice.isCorrect ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ],
                  ),
                  if (!selectedChoice.isCorrect) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Bonne réponse: ', 
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Expanded(
                          child: Text(
                            correctChoice.text,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Toutes les options:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            ...question.choices.map((choice) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: choice.id.toString() == selectedChoiceId
                    ? (choice.isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                    : choice.isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: choice.id.toString() == selectedChoiceId
                      ? (choice.isCorrect ? Colors.green.shade200 : Colors.red.shade200)
                      : choice.isCorrect
                          ? Colors.green.shade200
                          : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    choice.id.toString() == selectedChoiceId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: choice.id.toString() == selectedChoiceId
                        ? (choice.isCorrect ? Colors.green : Colors.red)
                        : choice.isCorrect
                            ? Colors.green
                            : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      choice.text,
                      style: TextStyle(
                        color: choice.id.toString() == selectedChoiceId
                            ? (choice.isCorrect ? Colors.green : Colors.red)
                            : choice.isCorrect
                                ? Colors.green
                                : null,
                        fontWeight: choice.isCorrect || choice.id.toString() == selectedChoiceId
                            ? FontWeight.w500
                            : null,
                      ),
                    ),
                  ),
                  if (choice.isCorrect)
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 16,
                    ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.quizTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Score: ${(result.score * 100).toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: result.score >= 0.5 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: result.score >= 0.5 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: result.score >= 0.5 ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Text(
                            result.score >= 0.5 ? 'Réussi' : 'Échoué',
                            style: TextStyle(
                              color: result.score >= 0.5 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terminé le ${result.completedAt.day}/${result.completedAt.month}/${result.completedAt.year} à ${result.completedAt.hour}:${result.completedAt.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (result.questions != null && result.questions!.isNotEmpty) ...[
              const Text(
                'Détails des réponses:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...result.questions!.map((question) {
                final selectedChoiceId = result.answers[question.id.toString()];
                return _buildAnswerDetails(context, question, selectedChoiceId);
              }).toList(),
            ] else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Les détails des questions ne sont pas disponibles pour ce résultat.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 