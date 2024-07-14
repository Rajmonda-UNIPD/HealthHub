import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late final StreamSubscription<MyUser?> _userSubsription;

  AuthenticationBloc({
    required this.userRepository
  }) : super(const AuthenticationState.unknown()) {
    _userSubsription = userRepository.user.listen((user) {
      add(AuthenticationUserChanged(user));
    });
    
    on<AuthenticationUserChanged>((event, emit) {
      if (event.user != MyUser.empty) {
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _userSubsription.cancel();
    return super.close();
  }
}
