import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';

class DataBloc extends HydratedBloc<DataEvent, DataState> {
  DataBloc() : super(DataState.initial()) {
    on<AddAddressDataEvent>((AddAddressDataEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(addressList: [...state.addressList, event.address]));
    });

    on<LoginToAccountsEvent>((LoginToAccountsEvent event, Emitter<DataState> emit) async {
      List<AddressData> updateAddressList = [];
      for (var address in state.addressList) {
        AuthenticatedUser? loggedInUser = await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
        if (loggedInUser == null) {
          updateAddressList.add(address.copyWith(isActive: false));
        } else {
          updateAddressList.add(address);
        }
      }
      emit(state.copyWith(addressList: updateAddressList));
    });

    on<SelectAddressEvent>((SelectAddressEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(selectedAddress: event.addressData));
    });

    on<SelectMessageEvent>((SelectMessageEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(selectedMessage: event.message));
    });

    on<DeleteAddressEvent>((DeleteAddressEvent event, Emitter<DataState> emit) {
      List<AddressData> addresses =
          state.addressList.where((a) => a.authenticatedUser.account.id != event.addressData.authenticatedUser.account.id).toList();
      event.addressData.authenticatedUser.delete();
      emit(state.copyWith(addressList: addresses));
    });
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
