import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';

class DataBloc extends HydratedBloc<DataEvent, DataState> {
  DataBloc() : super(const DataState.initial());

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
