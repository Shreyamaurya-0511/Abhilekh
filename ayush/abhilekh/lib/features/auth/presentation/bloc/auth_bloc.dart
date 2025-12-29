import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/auth_repository.dart';

class AuthBloc extends Cubit<bool> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(false) {
    // Listen to the stream immediately upon creation
    authRepository.userStream.listen((user) {
      emit(user != null);
    });
  }

  Future<void> login(String email, String password) async {
    try {
      await authRepository.signIn(email, password);
      // No need to emit; the listener above will handle the state change
    } catch (e) {
      // For simplicity in this factory code, we aren't handling error states separately 
      // but in a real app, you would emit an AuthError state here.
      rethrow; 
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await authRepository.register(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
  }
}