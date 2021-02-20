import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    print('onEvent: $event');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('onTransition: $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stacktrace) {
    print('onError: $error, $stacktrace');
    super.onError(cubit, error, stacktrace);
  }

  @override
  void onChange(Cubit cubit, Change change) {
    print('onChange: $cubit, $change');
    super.onChange(cubit, change);
  }
}
