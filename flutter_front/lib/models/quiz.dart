class Choice {
  final int id;
  final String text;
  final bool isCorrect;

  Choice({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'is_correct': isCorrect,
    };
  }
}

class Question {
  final int id;
  final String text;
  final List<Choice> choices;
  final int order;
  final int quizId;

  Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.order,
    required this.quizId,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      choices: (json['choices'] as List<dynamic>)
          .map((c) => Choice.fromJson(c))
          .toList(),
      order: json['order'] ?? 0,
      quizId: json['quiz'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'choices': choices.map((c) => c.toJson()).toList(),
      'order': order,
      'quiz': quizId,
    };
  }
}

class Quiz {
  final int id;
  final String title;
  final String description;
  final String difficulty;
  final String difficultyLabel;
  final int timeLimit;
  final List<Question> questions;
  final bool isDeleted;
  final int? category;
  final String? categoryName;
  final String createdAt;
  final int userId;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.difficultyLabel,
    required this.timeLimit,
    required this.questions,
    required this.isDeleted,
    required this.createdAt,
    required this.userId,
    this.category,
    this.categoryName,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: json['difficulty'],
      difficultyLabel: json['difficulty_label'],
      timeLimit: json['time_limit'],
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q))
          .toList(),
      isDeleted: json['is_deleted'] ?? false,
      category: json['category'],
      categoryName: json['category_name'],
      createdAt: json['created_at'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'difficulty_label': difficultyLabel,
      'time_limit': timeLimit,
      'questions': questions.map((q) => q.toJson()).toList(),
      'is_deleted': isDeleted,
      'category': category,
      'category_name': categoryName,
      'created_at': createdAt,
      'user': userId,
    };
  }
} 