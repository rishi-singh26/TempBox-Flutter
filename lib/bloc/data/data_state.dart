import 'package:equatable/equatable.dart';

class DataState extends Equatable {
  final bool isAuthenticated;
  final bool isLoading;
  final String errMess;

  const DataState({
    required this.errMess,
    required this.isAuthenticated,
    required this.isLoading,
  });

  const DataState.initial()
      : isAuthenticated = false,
        isLoading = false,
        errMess = '';

  DataState.fromJson(Map<String, dynamic> json)
      : isAuthenticated = json.containsKey('isAuthenticated') ? json['isAuthenticated'] as bool : false,
        isLoading = json.containsKey('isLoading') ? json['isLoading'] as bool : false,
        errMess = json.containsKey('errMess') ? json['errMess'] as String : '';

  Map<String, dynamic> toJson() => {
        'isAuthenticated': isAuthenticated,
        'isLoading': isLoading,
        'errMess': errMess,
      };

  @override
  List<Object> get props => [
        errMess,
        isAuthenticated,
        isLoading,
      ];
}
