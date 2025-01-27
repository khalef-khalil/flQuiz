import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../models/quiz.dart';
import '../../models/quiz_result.dart';

class QuizController extends GetxController {
  final _apiService = ApiService();
  final _isLoading = false.obs;
  final _error = ''.obs;
  final RxList<Quiz> _quizzes = <Quiz>[].obs;
  final RxList<QuizResult> _quizHistory = <QuizResult>[].obs;
  final Rx<Quiz?> _currentQuiz = Rx<Quiz?>(null);
  final RxInt _currentQuestionIndex = 0.obs;
  final RxMap<int, int> _selectedAnswers = <int, int>{}.obs;
  final Rx<QuizResult?> _lastResult = Rx<QuizResult?>(null);
  final RxList<Map<String, String>> _difficulties = <Map<String, String>>[].obs;
  
  // Filter variables
  final RxString _searchQuery = ''.obs;
  final Rx<String?> _selectedDifficulty = Rx<String?>(null);
  final Rx<int?> _selectedCategory = Rx<int?>(null);

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<Quiz> get quizzes => _filteredQuizzes;
  List<QuizResult> get quizHistory => _quizHistory;
  Quiz? get currentQuiz => _currentQuiz.value;
  int get currentQuestionIndex => _currentQuestionIndex.value;
  set currentQuestionIndex(int value) => _currentQuestionIndex.value = value;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  QuizResult? get lastResult => _lastResult.value;
  List<Map<String, String>> get difficulties => _difficulties;
  
  // Filter getters
  String get searchQuery => _searchQuery.value;
  String? get selectedDifficulty => _selectedDifficulty.value;
  int? get selectedCategory => _selectedCategory.value;

  // Filtered quizzes
  List<Quiz> get _filteredQuizzes {
    return _quizzes.where((quiz) {
      // Apply search filter
      if (_searchQuery.value.isNotEmpty &&
          !quiz.title.toLowerCase().contains(_searchQuery.value.toLowerCase())) {
        return false;
      }
      
      // Apply difficulty filter
      if (_selectedDifficulty.value != null &&
          quiz.difficulty != _selectedDifficulty.value) {
        return false;
      }
      
      // Apply category filter
      if (_selectedCategory.value != null &&
          quiz.category != _selectedCategory.value) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void setSelectedDifficulty(String? difficulty) {
    _selectedDifficulty.value = difficulty;
  }

  void setSelectedCategory(int? categoryId) {
    _selectedCategory.value = categoryId;
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedDifficulty.value = null;
    _selectedCategory.value = null;
  }

  @override
  void onInit() {
    super.onInit();
    ever(_error, (_) {
      if (_error.value.isNotEmpty) {
        Get.snackbar(
          'Erreur',
          _error.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    });
    _initData();
  }

  Future<void> _initData() async {
    // Initialize difficulties with default values
    _difficulties.assignAll([
      {'value': 'facile', 'label': 'Facile'},
      {'value': 'moyen', 'label': 'Moyen'},
      {'value': 'difficile', 'label': 'Difficile'},
    ]);
    
    await Future.wait([
      fetchQuizzes(),
    ]);
  }

  Future<void> fetchQuizzes() async {
    _error.value = '';
    _isLoading.value = true;

    try {
      final quizzes = await _apiService.getQuizzes();
      _quizzes.assignAll(quizzes);
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        // Token expired, handled by ApiService
        return;
      }
      _error.value = 'Échec du chargement des quiz';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchQuizHistory() async {
    print('QuizController: Starting to fetch quiz history');
    try {
      _isLoading.value = true;
      _error.value = '';
      print('QuizController: Calling API service to get quiz history');
      final history = await _apiService.getQuizHistory();
      print('QuizController: Received quiz history data: ${history.length} items');

      // Fetch quiz details for each result
      final updatedHistory = await Future.wait(
        history.map((result) async {
          try {
            final quiz = await _apiService.getQuiz(result.quizId);
            return QuizResult(
              id: result.id,
              quizId: result.quizId,
              quizTitle: result.quizTitle,
              username: result.username,
              score: result.score,
              completedAt: result.completedAt,
              answers: result.answers,
              questions: quiz.questions,
            );
          } catch (e) {
            print('QuizController: Error fetching quiz ${result.quizId}: $e');
            return result;
          }
        }),
      );

      _quizHistory.assignAll(updatedHistory);
      print('QuizController: Quiz history updated in state');
    } catch (e) {
      print('QuizController: Error fetching quiz history: $e');
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
      print('QuizController: Finished fetching quiz history');
    }
  }

  Future<void> fetchDifficulties() async {
    try {
      final difficulties = await _apiService.getDifficulties();
      _difficulties.assignAll(difficulties);
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        // Token expired, handled by ApiService
        return;
      }
      _error.value = 'Échec du chargement des difficultés';
    }
  }

  void startQuiz(Quiz quiz) {
    _currentQuiz.value = quiz;
    _currentQuestionIndex.value = 0;
    _selectedAnswers.clear();
    _lastResult.value = null;
  }

  void selectAnswer(int questionIndex, int choiceIndex) {
    _selectedAnswers[questionIndex] = choiceIndex;
  }

  bool get canMoveToNextQuestion {
    return _selectedAnswers.containsKey(_currentQuestionIndex.value);
  }

  void nextQuestion() {
    if (_currentQuestionIndex.value < currentQuiz!.questions.length - 1) {
      _currentQuestionIndex.value++;
    }
  }

  bool get isLastQuestion {
    return _currentQuestionIndex.value == currentQuiz!.questions.length - 1;
  }

  Future<void> submitQuiz() async {
    if (currentQuiz == null) return;

    _isLoading.value = true;
    _error.value = '';

    try {
      // Calculate score and correct answers
      int correctAnswers = 0;
      for (var entry in _selectedAnswers.entries) {
        final question = currentQuiz!.questions[entry.key];
        final selectedChoice = question.choices[entry.value];
        if (selectedChoice.isCorrect) {
          correctAnswers++;
        }
      }
      final score = correctAnswers / currentQuiz!.questions.length;

      // Convert answers to the format expected by the API
      final answers = _selectedAnswers.map((key, value) => MapEntry(
        currentQuiz!.questions[key].id.toString(),
        currentQuiz!.questions[key].choices[value].id.toString(),
      ));

      // Submit the result to the backend to store in history
      final result = await _apiService.submitQuizResult(
        currentQuiz!.id,
        score,
        answers,
        correctAnswers,
      );

      // Store the result locally for displaying on the results page
      final resultWithQuestions = QuizResult(
        id: result.id,
        quizId: result.quizId,
        quizTitle: result.quizTitle,
        username: result.username,
        score: result.score,
        completedAt: result.completedAt,
        answers: result.answers,
        questions: currentQuiz!.questions,
      );

      _lastResult.value = resultWithQuestions;
      // No need to fetch quiz history here, as we are storing the result locally
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        // Token expired, handled by ApiService
        return;
      }
      _error.value = 'Échec de la soumission du quiz';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> createQuiz({
    required String title,
    required String description,
    required int category,
    required String difficulty,
    required int timeLimit,
    required List<Map<String, dynamic>> questions,
  }) async {
    print('QuizController: Starting quiz creation');
    print('QuizController: Title: $title');
    print('QuizController: Description: $description');
    print('QuizController: Category: $category');
    print('QuizController: Difficulty: $difficulty');
    print('QuizController: Time limit: $timeLimit');
    print('QuizController: Questions: $questions');
    
    _error.value = '';
    _isLoading.value = true;

    try {
      print('QuizController: Calling API service to create quiz');
      final quiz = await _apiService.createQuiz(
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        timeLimit: timeLimit,
        questions: questions,
      );
      print('QuizController: Quiz created successfully with ID: ${quiz.id}');
      await fetchQuizzes();
      return true;
    } catch (e) {
      print('QuizController: Error creating quiz: $e');
      _error.value = e.toString();
      return false;
    } finally {
      _isLoading.value = false;
      print('QuizController: Quiz creation process completed');
    }
  }

  Future<bool> deleteQuiz(int id) async {
    _error.value = '';
    _isLoading.value = true;

    try {
      await _apiService.deleteQuiz(id);
      _quizzes.removeWhere((quiz) => quiz.id == id);
      return true;
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        // Token expired, handled by ApiService
        return false;
      }
      _error.value = 'Échec de la suppression du quiz';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void resetQuiz() {
    _currentQuiz.value = null;
    _currentQuestionIndex.value = 0;
    _selectedAnswers.clear();
    _lastResult.value = null;
  }
} 