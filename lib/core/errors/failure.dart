import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class ServerFailure extends Failure {
  const ServerFailure({required String message, String? code}) 
      : super(message: message, code: code);
}
