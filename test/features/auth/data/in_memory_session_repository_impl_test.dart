import 'package:ai_flutter_sample/features/auth/data/repositories/in_memory_session_repository_impl.dart';
import 'package:ai_flutter_sample/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySessionRepositoryImpl repository;

  setUp(() {
    repository = InMemorySessionRepositoryImpl();
  });

  test('returns null before any login', () {
    expect(repository.currentUser, isNull);
  });

  test('returns the saved user', () {
    const user = User(email: 'tikson@qburst.com');

    repository.save(user);

    expect(repository.currentUser, user);
  });

  test('overwrites a previously saved user', () {
    const oldUser = User(email: 'old@qburst.com');
    const newUser = User(email: 'tikson@qburst.com');
    repository.save(oldUser);

    repository.save(newUser);

    expect(repository.currentUser, newUser);
  });

  test('clear resets the session to null', () {
    const user = User(email: 'tikson@qburst.com');
    repository.save(user);

    repository.clear();

    expect(repository.currentUser, isNull);
  });
}
