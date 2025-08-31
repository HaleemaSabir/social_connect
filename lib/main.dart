import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:social_connect/services/auth_service.dart';
import 'package:social_connect/services/notification_service.dart';
import 'package:social_connect/screens/search_screen.dart';
import 'package:social_connect/screens/splash_screen.dart';
import 'package:social_connect/screens/login_screen.dart';
import 'package:social_connect/screens/signup_screen.dart';
import 'package:social_connect/screens/forgot_password_screen.dart';
import 'package:social_connect/screens/home_screen.dart';
import 'package:social_connect/screens/create_post_screen.dart';
import 'package:social_connect/screens/post_feed_screen.dart';
import 'package:social_connect/screens/profile_screen.dart';
import 'package:social_connect/screens/edit_profile_screen.dart';
import 'package:social_connect/screens/settings_screen.dart';
import 'package:social_connect/screens/notifications_screen.dart';
import 'package:social_connect/screens/chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.teal[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/create-post': (context) => const CreatePostScreen(),
        '/feed': (context) => const PostFeedScreen(),
        '/search': (context) => const SearchScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/chats': (context) => const ChatListScreen(),
      },
    );
  }
}
