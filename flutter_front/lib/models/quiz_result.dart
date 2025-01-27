import 'quiz.dart';

class QuizResult {
  final int id;
  final int quizId;
  final String quizTitle;
  final String username;
  final double score;
  final DateTime completedAt;
  final Map<String, dynamic> answers;
  final List<Question>? questions;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.username,
    required this.score,
    required this.completedAt,
    required this.answers,
    this.questions,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      quizId: json['quiz_id'],
      quizTitle: json['quiz_title'],
      username: json['username'],
      score: (json['score'] as num).toDouble(),
      completedAt: DateTime.parse(json['completed_at']),
      answers: Map<String, dynamic>.from(json['answers']),
      questions: json['questions'] != null 
          ? (json['questions'] as List<dynamic>)
              .map((q) => Question.fromJson(q))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'quiz_title': quizTitle,
      'username': username,
      'score': score,
      'completed_at': completedAt.toIso8601String(),
      'answers': answers,
      if (questions != null)
        'questions': questions!.map((q) => q.toJson()).toList(),
    };
  }
} 