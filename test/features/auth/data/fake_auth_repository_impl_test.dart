import 'package:ai_flutter_sample/features/auth/data/repositories/fake_auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('completes without error after one second', (tester) async {
    var completed = false;
    const FakeAuthRepositoryImpl()
        .login(email: 'user@example.com', password: 'secret1')
        .then((_) => completed = true);

    await tester.pump(const Duration(milliseconds: 999));
    expect(completed, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(completed, isTrue);
  });
}
