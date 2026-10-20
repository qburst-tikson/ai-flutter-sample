import 'package:ai_flutter_sample/core/usecase/usecase.dart';
import 'package:ai_flutter_sample/features/auth/domain/repositories/session_repository.dart';
import 'package:ai_flutter_sample/features/auth/domain/usecases/logout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

void main() {
  late _MockSessionRepository sessionRepository;
  late Logout logout;

  setUp(() {
    sessionRepository = _MockSessionRepository();
    logout = Logout(sessionRepository);
  });

  test('clears the session', () async {
    await logout(const NoParams());

    verify(() => sessionRepository.clear()).called(1);
  });
}
