import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/create_quiz_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/category_page.dart';
import 'presentation/pages/quiz_history_page.dart';
import 'presentation/pages/quiz_details_page.dart';
import 'presentation/pages/quiz_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/quiz_controller.dart';
import 'presentation/controllers/category_controller.dart';
import 'models/quiz.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await GetStorage.init();
  
  // Initialize controllers
  Get.put(AuthController(), permanent: true);
  
  // Initialize your app
  runApp(const QuizApp());
  
  // Remove splash screen once your app is ready
  FlutterNativeSplash.remove();
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      defaultTransition: Transition.fade,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterPage(),
        ),
        GetPage(
          name: '/',
          page: () => HomePage(),
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(QuizController());
            Get.put(CategoryController());
          }),
        ),
        GetPage(
          name: '/create-quiz',
          page: () => const CreateQuizPage(),
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(QuizController());
            Get.put(CategoryController());
          }),
        ),
        GetPage(
          name: '/profile',
          page: () => ProfilePage(),
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(QuizController());
          }),
        ),
        GetPage(
          name: '/categories',
          page: () => CategoryPage(),
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(CategoryController());
          }),
        ),
        GetPage(
          name: '/history',
          page: () => QuizHistoryPage(),
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(QuizController());
          }),
        ),
        GetPage(
          name: '/quiz/:id',
          page: () {
            try {
              final quizId = int.parse(Get.parameters['id'] ?? '');
              final quiz = Get.find<QuizController>().quizzes.firstWhere(
                (q) => q.id == quizId,
                orElse: () => throw Exception('Quiz not found'),
              );
              return QuizDetailsPage(quiz: quiz);
            } catch (e) {
              Get.snackbar('Error', 'Quiz not found');
              Get.offAllNamed('/');
              throw Exception('Quiz not found');
            }
          },
          middlewares: [RouteGuard()],
          binding: BindingsBuilder(() {
            Get.put(QuizController());
          }),
        ),
      ],
    );
  }
}

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == '/login') return null;
    
    try {
      final storage = GetStorage();
      final token = storage.read('token');
      final authController = Get.find<AuthController>();
      
      if (token == null || !authController.isLoggedIn) {
        return const RouteSettings(name: '/login');
      }
      return null;
    } catch (e) {
      return const RouteSettings(name: '/login');
    }
  }
} 