import 'package:equatable/equatable.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();
}

// class SignUpStartEvent extends DataEvent {
//   final String email;
//   final String password;

//   const SignUpStartEvent(this.email, this.password);
//   @override
//   List<Object> get props => [email, password];
// }
