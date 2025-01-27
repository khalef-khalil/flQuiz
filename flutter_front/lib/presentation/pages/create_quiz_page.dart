import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../controllers/category_controller.dart';

class Question {
  String text = '';
  List<String> choices = ['', '', '', ''];
  int correctChoiceIndex = 0;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'choices': List.generate(choices.length, (index) => {
        'text': choices[index],
        'is_correct': index == correctChoiceIndex,
      }),
      'order': 0, // Sera défini par le backend
    };
  }
}

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({super.key});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final _quizController = Get.find<QuizController>();
  final _categoryController = Get.find<CategoryController>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedDifficulty;
  final _timeLimitController = TextEditingController(text: '30');
  final List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _categoryController.fetchCategories();
    _quizController.fetchDifficulties();
    _addQuestion(); // Add initial question
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(Question());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _submitQuiz() async {
    print('CreateQuizPage: Starting quiz submission');
    if (!_formKey.currentState!.validate()) {
      print('CreateQuizPage: Form validation failed');
      return;
    }

    if (_selectedCategory == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une catégorie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Get category ID from selected category name
    final categoryId = _categoryController.getCategoryId(_selectedCategory!);
    if (categoryId == null) {
      Get.snackbar(
        'Erreur',
        'Catégorie invalide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // Validate that each question has all choices filled
    for (var i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.text.isEmpty) {
        print('CreateQuizPage: Question ${i + 1} is empty');
        Get.snackbar(
          'Erreur',
          'La question ${i + 1} est vide',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
        return;
      }
      
      for (var j = 0; j < question.choices.length; j++) {
        if (question.choices[j].isEmpty) {
          print('CreateQuizPage: Choice ${j + 1} of question ${i + 1} is empty');
          Get.snackbar(
            'Erreur',
            'Le choix ${j + 1} de la question ${i + 1} est vide',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return;
        }
      }
    }

    print('CreateQuizPage: Form validation passed');
    print('CreateQuizPage: Title: ${_titleController.text}');
    print('CreateQuizPage: Description: ${_descriptionController.text}');
    print('CreateQuizPage: Category: $categoryId');
    print('CreateQuizPage: Difficulty: $_selectedDifficulty');
    print('CreateQuizPage: Time limit: ${_timeLimitController.text}');
    
    final questionsJson = _questions.map((q) {
      final json = q.toJson();
      print('CreateQuizPage: Question data: $json');
      return json;
    }).toList();
    print('CreateQuizPage: Total questions: ${questionsJson.length}');

    final success = await _quizController.createQuiz(
      title: _titleController.text,
      description: _descriptionController.text,
      category: categoryId,
      difficulty: _selectedDifficulty!,
      timeLimit: int.parse(_timeLimitController.text),
      questions: questionsJson,
    );

    if (success) {
      print('CreateQuizPage: Quiz created successfully');
      Get.back();
    } else {
      print('CreateQuizPage: Quiz creation failed');
    }
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Question ${index + 1}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _questions.length > 1 ? () => _removeQuestion(index) : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une question';
                }
                return null;
              },
              onChanged: (value) => question.text = value,
            ),
            const SizedBox(height: 16),
            const Text('Choix:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(4, (choiceIndex) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Radio<int>(
                    value: choiceIndex,
                    groupValue: question.correctChoiceIndex,
                    onChanged: (value) {
                      setState(() {
                        question.correctChoiceIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Choix ${choiceIndex + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un choix';
                        }
                        return null;
                      },
                      onChanged: (value) => question.choices[choiceIndex] = value,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La description est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GetX<CategoryController>(
                builder: (controller) {
                  final categories = controller.categories;
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      final name = category['name'] as String?;
                      if (name == null) return null;
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).whereType<DropdownMenuItem<String>>().toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La catégorie est requise';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulté',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'facile', child: Text('Facile')),
                  DropdownMenuItem(value: 'moyen', child: Text('Moyen')),
                  DropdownMenuItem(value: 'difficile', child: Text('Difficile')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La difficulté est requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Temps limite (en minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le temps limite est requis';
                  }
                  final timeLimit = int.tryParse(value);
                  if (timeLimit == null || timeLimit <= 0) {
                    return 'Le temps limite doit être un nombre positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              const Text('Questions:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...List.generate(_questions.length, (index) => _buildQuestionCard(index)),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une question'),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Créer le quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 