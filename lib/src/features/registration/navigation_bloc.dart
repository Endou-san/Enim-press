import 'package:flutter_bloc/flutter_bloc.dart';

// Define the navigation event
abstract class NavigationEvent {}

// Event triggered when the button is pressed
class ButtonPressedEvent extends NavigationEvent {}

// Define the navigation state
abstract class NavigationState {}

// Initial state
class InitialNavigationState extends NavigationState {}

// State to represent the other page
class OtherPageState extends NavigationState {}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(InitialNavigationState());

  @override
  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is ButtonPressedEvent) {
      // Emit the OtherPageState to navigate to the other page
      yield OtherPageState();
    }
  }
}
