import 'package:answer/answer.dart';

abstract class PageState<S extends Object?> {
  bool isSuccess() => this is SuccessState;

  bool get isLoading => this is LoadingState;

  bool get isError => this is ErrorState;

  S get asSuccess => (this as SuccessState).data as S;

  AnswerFailure get asError => (this as ErrorState).error;
}

class InitialState<S extends Object?> extends PageState<S> {}

class LoadingState<S extends Object?> extends PageState<S> {
  final String? message;

  LoadingState({this.message});
}

class ErrorState<S extends Object?> extends PageState<S> {
  final AnswerFailure error;

  ErrorState({required this.error});
}

class SuccessState<S extends Object?> extends PageState<S> {
  final S data;
  SuccessState({required this.data});
}
