import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';
import 'screens/auth/blocs/sign_in_block/sign_in_bloc.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(userRepository: userRepository),
        ),
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(userRepository),
        ),
      ],
      child: const MyAppView(),
    );
  }
}
