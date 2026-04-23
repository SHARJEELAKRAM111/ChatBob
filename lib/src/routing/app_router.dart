import 'package:flutter/material.dart';
import 'package:chatbob/src/routing/app_routes.dart';

import 'package:chatbob/src/ui/auth/login_screen.dart';
import 'package:chatbob/src/ui/auth/signup_screen.dart';
import 'package:chatbob/src/ui/auth/forgot_password_screen.dart';

import 'package:chatbob/src/ui/home/home_page.dart';
import 'package:chatbob/src/ui/onboarding/onboarding_page.dart';
import 'package:chatbob/src/ui/chat/chat_screen.dart';
import 'package:chatbob/src/ui/contacts/contacts_screen.dart';
import 'package:chatbob/src/ui/profile/profile_screen.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'] as String,
            otherUserId: args['otherUserId'] as String,
            otherUserName: args['otherUserName'] as String,
            otherUserPhoto: args['otherUserPhoto'] as String?,
          ),
          settings: settings,
        );
      case AppRoutes.contacts:
        return MaterialPageRoute(
          builder: (_) => const ContactsScreen(),
          settings: settings,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
    }
  }
}
