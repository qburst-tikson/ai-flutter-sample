import 'package:equatable/equatable.dart';

class Greeting extends Equatable {
  const Greeting({required this.title, required this.message});

  final String title;
  final String message;

  @override
  List<Object?> get props => [title, message];
}
