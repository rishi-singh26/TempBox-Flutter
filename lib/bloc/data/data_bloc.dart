import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';

class DataBloc extends HydratedBloc<DataEvent, DataState> {
  DataBloc() : super(DataState.initial()) {
    on<AddAddressData>((AddAddressData event, Emitter<DataState> emit) {
      emit(state.copyWith(addressList: [...state.addressList, event.address]));
    });
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
