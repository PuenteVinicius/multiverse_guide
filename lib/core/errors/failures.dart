// Failures são usados na camada de domínio para representar erros
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class NetworkFailure extends Failure {}

class GeneralFailure extends Failure {}
