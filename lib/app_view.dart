import 'package:flutter/material.dart';
import 'package:flutter_app/screens/auth/views/welcome_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:flutter_app/screens/home/views/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade200,
          onSurface: Colors.black,
          primary: Colors.blue,
          onPrimary: Colors.white,
        ),
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.authenticated) {
            return const HomeScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
