import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for web, and your machine's IP for iOS simulator
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final storage = GetStorage();

  String? get token => storage.read('token');

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Token ${token ?? ''}',
  };

  void _handleUnauthorized() {
    storage.remove('token');
    storage.remove('user');
    Get.offAllNamed('/login');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        storage.write('token', data['token']);
        storage.write('user', data['user']);
        return data;
      } else {
        throw Exception('Échec de la connexion');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      throw Exception('Échec de la connexion');
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        storage.write('token', data['token']);
        storage.write('user', data['user']);
        return data;
      } else {
        throw Exception('Échec de l\'inscription');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      throw Exception('Échec de l\'inscription');
    }
  }

  Future<List<Quiz>> getQuizzes() async {
    try {
      print('ApiService: Fetching quizzes');
      print('ApiService: Using token: $token');
      print('ApiService: Using URL: $baseUrl/quizzes/');
      
      if (token == null) {
        print('ApiService: No token found');
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quizzes/'),
        headers: headers,
      );

      print('ApiService: Response status code: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        print('ApiService: Parsing response body as JSON');
        final List<dynamic> data = jsonDecode(response.body);
        print('ApiService: Successfully decoded JSON. Number of quizzes: ${data.length}');
        print('ApiService: First quiz data (if exists): ${data.isNotEmpty ? data.first : 'No quizzes'}');
        
        final quizzes = data.map((json) {
          print('ApiService: Converting quiz JSON to object: $json');
          try {
            return Quiz.fromJson(json);
          } catch (e) {
            print('ApiService: Error parsing quiz: $e');
            rethrow;
          }
        }).toList();
        
        print('ApiService: Successfully converted ${quizzes.length} quizzes');
        return quizzes;
      } else if (response.statusCode == 401) {
        print('ApiService: Unauthorized access - token may be invalid');
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        print('ApiService: Unexpected status code: ${response.statusCode}');
        throw Exception('Échec du chargement des quiz: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('ApiService: Socket Exception: $e');
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      print('ApiService: Unexpected error: $e');
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Échec du chargement des quiz: $e');
    }
  }

  Future<Quiz> getQuiz(int id) async {
    try {
      if (token == null) {
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quizzes/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Quiz.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        throw Exception('Échec du chargement du quiz');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Échec du chargement du quiz');
    }
  }

  Future<List<QuizResult>> getQuizHistory() async {
    print('ApiService: Starting to fetch quiz history');
    try {
      if (token == null) {
        print('ApiService: No token found');
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      print('ApiService: Token found, making request to: $baseUrl/results/');
      print('ApiService: Headers: $headers');
      
      final response = await http.get(
        Uri.parse('$baseUrl/results/'),
        headers: headers,
      );

      print('ApiService: Response status: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('ApiService: Parsing response body');
        final List<dynamic> data = json.decode(response.body);
        print('ApiService: Successfully parsed ${data.length} results');
        
        final results = data.map((json) {
          print('ApiService: Converting result: $json');
          return QuizResult.fromJson(json);
        }).toList();
        
        print('ApiService: Successfully converted ${results.length} results');
        return results;
      } else if (response.statusCode == 401) {
        print('ApiService: Unauthorized - token may be expired');
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        print('ApiService: Error response ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load quiz history');
      }
    } catch (e) {
      print('ApiService: Error in getQuizHistory: $e');
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Failed to load quiz history: $e');
    }
  }

  Future<QuizResult> submitQuizResult(int quizId, double score, Map<String, dynamic> answers, int correctAnswers) async {
    try {
      if (token == null) {
        print('ApiService: No token found, handling unauthorized');
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      print('ApiService: Submitting quiz result');
      print('ApiService: Quiz ID: $quizId');
      print('ApiService: Score: $score');
      print('ApiService: Answers: $answers');

      final requestBody = {
        'score': score,
        'answers': answers,
        'correct_answers': correctAnswers,
      };
      print('ApiService: Request body: ${jsonEncode(requestBody)}');
      print('ApiService: Request headers: $headers');
      print('ApiService: Request URL: $baseUrl/quizzes/$quizId/submit_result/');

      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/$quizId/submit_result/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('ApiService: Response status: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('ApiService: Quiz result submitted successfully');
        return QuizResult.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        print('ApiService: Unauthorized - token may be expired');
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        print('ApiService: Error response from server');
        print('ApiService: Error details: ${response.body}');
        throw Exception('Failed to submit quiz result');
      }
    } catch (e) {
      print('ApiService: Error in submitQuizResult: $e');
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Failed to submit quiz result: $e');
    }
  }

  Future<List<Map<String, String>>> getDifficulties() async {
    try {
      if (token == null) {
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quizzes/difficulties/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'value': item['value'] as String,
          'label': item['label'] as String,
        }).toList();
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        throw Exception('Échec du chargement des difficultés');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Échec du chargement des difficultés');
    }
  }

  void logout() {
    storage.remove('token');
    storage.remove('user');
  }

  Future<Quiz> createQuiz({
    required String title,
    required String description,
    required int category,
    required String difficulty,
    required int timeLimit,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      if (token == null) {
        print('ApiService: No token found, handling unauthorized');
        _handleUnauthorized();
        throw Exception('token_expired');
      }

      print('ApiService: Creating quiz with data:');
      print('ApiService: Title: $title');
      print('ApiService: Description: $description');
      print('ApiService: Category: $category');
      print('ApiService: Difficulty: $difficulty');
      print('ApiService: Time limit: $timeLimit');
      print('ApiService: Questions: $questions');

      final requestBody = {
        'title': title,
        'description': description,
        'category': category,
        'difficulty': difficulty,
        'time_limit': timeLimit,
        'questions': questions,
      };
      print('ApiService: Request body: ${jsonEncode(requestBody)}');
      print('ApiService: Request headers: $headers');
      print('ApiService: Request URL: $baseUrl/quizzes/');

      final response = await http.post(
        Uri.parse('$baseUrl/quizzes/'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('ApiService: Response status: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('ApiService: Quiz created successfully, parsing response');
        final json = jsonDecode(response.body);
        print('ApiService: Decoded JSON: $json');
        try {
          final quiz = Quiz.fromJson(json);
          print('ApiService: Successfully created Quiz object with ID: ${quiz.id}');
          return quiz;
        } catch (e) {
          print('ApiService: Error parsing Quiz from JSON: $e');
          rethrow;
        }
      } else if (response.statusCode == 401) {
        print('ApiService: Unauthorized - token may be invalid');
        _handleUnauthorized();
        throw Exception('token_expired');
      } else {
        print('ApiService: Error response from server');
        final error = jsonDecode(response.body);
        print('ApiService: Error details: $error');
        throw Exception(error['detail'] ?? 'Failed to create quiz');
      }
    } catch (e) {
      print('ApiService: Error in createQuiz: $e');
      if (e.toString().contains('token_expired')) {
        rethrow;
      }
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<Quiz> updateQuiz({
    required int id,
    required String title,
    required String description,
    required String categoryName,
    required String difficulty,
    required int timeLimit,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quizzes/$id/'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'category_name': categoryName,
          'difficulty': difficulty,
          'time_limit': timeLimit,
        }),
      );

      if (response.statusCode == 200) {
        return Quiz.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Échec de la mise à jour du quiz');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      throw Exception('Échec de la mise à jour du quiz');
    }
  }

  Future<void> deleteQuiz(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quizzes/$id/'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression du quiz');
      }
    } on SocketException {
      throw Exception('Échec de la connexion au serveur');
    } catch (e) {
      throw Exception('Échec de la suppression du quiz');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    print('ApiService: Fetching categories');
    print('ApiService: Using token: $token');
    print('ApiService: Using URL: $baseUrl/categories/');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/'),
        headers: headers,
      );

      print('ApiService: Response status code: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('ApiService: Error fetching categories: $e');
      rethrow;
    }
  }

  Future<void> createCategory(String name, String description) async {
    print('ApiService: Creating category: $name');
    final response = await http.post(
      Uri.parse('$baseUrl/categories/'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode != 201) {
      print('ApiService: Error status code: ${response.statusCode}');
      throw Exception('Failed to create category');
    }
  }

  Future<void> deleteCategory(int id) async {
    print('ApiService: Deleting category with ID: $id');
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/$id/'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      print('ApiService: Error status code: ${response.statusCode}');
      throw Exception('Failed to delete category');
    }
  }
} 