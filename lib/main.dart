// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:snap_tale/screen/story_detail_screen.dart';
import 'package:snap_tale/screen/home_screen.dart';
import 'package:snap_tale/screen/story_add_screen.dart';
import 'package:snap_tale/common.dart';

import 'data/controller/auth/auth_controller.dart';
import 'data/controller/locale_controller.dart';
import 'screen/auth/login_screen.dart';
import 'screen/auth/register_screen.dart';


final AuthController authController = Get.put(AuthController());

Future<void> mainApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(LocaleController());
  runApp(const MyApp());
}

final GoRouter router = GoRouter(
  refreshListenable: authController,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        return authController.isAuthenticated.value ? '/home' : '/login';
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: StoryDetailScreen(storyId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(path: '/add-story', builder: (context, state) => const StoryAddScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return FutureBuilder(
      future: authController.checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GetMaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return GetMaterialApp.router(
          title: 'Flutter Demo',
          locale: localeController.locale,
          supportedLocales: localeController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
          ),
          routerDelegate: router.routerDelegate,
          backButtonDispatcher: router.backButtonDispatcher,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}
