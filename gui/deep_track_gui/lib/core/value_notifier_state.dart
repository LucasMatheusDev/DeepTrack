
import 'package:answer/answer.dart';
import 'package:deep_track_gui/core/page_state.dart';
import 'package:flutter/material.dart';

class ValueNotifierState<T> extends ValueNotifier<PageState<T>> {
  ValueNotifierState() : super(InitialState<T>());

  void changeToLoadingState([String? message]) {
    value = LoadingState(message: message);
  }

  void changeToErrorState(AnswerFailure error) {
    value = ErrorState(error: error);
  }

  void changeToSuccessState(T data) {
    value = SuccessState(data: data);
  }

  bool get isLoading => value.isLoading;

  bool get isError => value.isError;

  bool get isSuccess => value.isSuccess();

  T get asSuccess => value.asSuccess;

  AnswerFailure get asError => value.asError;
}
