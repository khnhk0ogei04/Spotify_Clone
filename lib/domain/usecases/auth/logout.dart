import 'package:dartz/dartz.dart';
import 'package:spotify_clone/domain/repository/auth/auth.dart';
import 'package:spotify_clone/service_locator.dart';

class LogoutUseCase {
  final AuthRepository _authRepository = sl.get<AuthRepository>();

  Future<Either> execute() async {
    return await _authRepository.logout();
  }
} 