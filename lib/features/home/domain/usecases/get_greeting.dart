import '../../../../core/usecase/usecase.dart';
import '../entities/greeting.dart';
import '../repositories/greeting_repository.dart';

class GetGreeting implements UseCase<Greeting, NoParams> {
  const GetGreeting(this._repository);

  final GreetingRepository _repository;

  @override
  Future<Greeting> call(NoParams params) => _repository.getGreeting();
}
