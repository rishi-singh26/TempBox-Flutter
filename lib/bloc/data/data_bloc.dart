import 'package:flutter/foundation.dart';
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
      try {
        for (var address in state.addressList) {
          await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      // List<AddressData> updateAddressList = [];
      // for (var address in state.addressList) {
      //   AuthenticatedUser? loggedInUser = await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
      //   if (loggedInUser == null) {
      //     updateAddressList.add(address.copyWith(isActive: false));
      //   } else {
      //     updateAddressList.add(address);
      //   }
      // }
      // emit(state.copyWith(addressList: updateAddressList));
    });

    on<SelectAddressEvent>((SelectAddressEvent event, Emitter<DataState> emit) {
      if (state.selectedAddress?.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id) {
        return;
      }
      emit(state.copyWith(selectedAddress: event.addressData, setSelectedMessageToNull: true));
    });

    on<DeleteAddressEvent>((DeleteAddressEvent event, Emitter<DataState> emit) async {
      List<AddressData> addresses =
          state.addressList.where((a) => a.authenticatedUser.account.id != event.addressData.authenticatedUser.account.id).toList();
      await event.addressData.authenticatedUser.delete();
      if (state.selectedAddress != null) {
        AddressData? selectedAddress =
            addresses.where((a) => a.authenticatedUser.account.id == state.selectedAddress!.authenticatedUser.account.id).firstOrNull;
        if (selectedAddress == null) {
          emit(state.copyWith(addressList: addresses, setSelectedAddressToNull: true));
          return;
        }
      }
      emit(state.copyWith(addressList: addresses));
    });

    on<GetMessagesEvent>((GetMessagesEvent event, Emitter<DataState> emit) async {
      event.resetMessages == true ? emit(state.copyWith(messagesList: [], isMessagesLoading: true)) : null;
      final messages = await event.addressData.authenticatedUser.messagesAt(1);
      if (state.selectedMessage != null) {
        Message? selectedMessage = messages.where((m) => m.id == state.selectedMessage!.id).firstOrNull;
        if (selectedMessage != null) {
          emit(state.copyWith(messagesList: messages, isMessagesLoading: false, selectedMessage: selectedMessage));
          return;
        }
      }
      emit(state.copyWith(messagesList: messages, isMessagesLoading: false));
    });

    on<ToggleMessageReadUnread>((ToggleMessageReadUnread event, Emitter<DataState> emit) async {
      if (event.message.seen) {
        await event.addressData.authenticatedUser.unreadMessage(event.message.id);
      } else {
        await event.addressData.authenticatedUser.readMessage(event.message.id);
      }
      add(GetMessagesEvent(addressData: event.addressData, resetMessages: event.resetMessages));
    });

    on<SelectMessageEvent>((SelectMessageEvent event, Emitter<DataState> emit) async {
      if (state.selectedMessage?.id == event.message.id) {
        return;
      }
      await event.addressData.authenticatedUser.readMessage(event.message.id);
      emit(state.copyWith(selectedMessage: event.message));
    });

    on<DeleteMessageEvent>((DeleteMessageEvent event, Emitter<DataState> emit) async {
      List<Message> messages = state.messagesList.where((m) => m.id != event.message.id).toList();
      await event.addressData.authenticatedUser.deleteMessage(event.message.id);
      if (state.selectedMessage != null) {
        Message? selectedMessage = messages.where((m) => m.id == state.selectedMessage!.id).firstOrNull;
        if (selectedMessage == null) {
          emit(state.copyWith(messagesList: messages, setSelectedMessageToNull: true));
          return;
        }
      }
      emit(state.copyWith(messagesList: messages));
    });
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
