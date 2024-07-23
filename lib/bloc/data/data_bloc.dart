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
        List<AddressData> updateAddressList = [];
        Map<String, List<Message>> accountIdToAddressesMap = {};
        for (var address in state.addressList) {
          AuthenticatedUser? loggedInUser = await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
          if (loggedInUser == null) {
            updateAddressList.add(address.copyWith(isActive: false));
          } else {
            final messages = await loggedInUser.messagesAt(1);
            messages.isNotEmpty ? accountIdToAddressesMap[loggedInUser.account.id] = messages : null;
            updateAddressList.add(address);
          }
        }
        emit(state.copyWith(addressList: updateAddressList, accountIdToAddressesMap: accountIdToAddressesMap));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<SelectAddressEvent>((SelectAddressEvent event, Emitter<DataState> emit) {
      if (state.selectedAddress?.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id) {
        return;
      }
      emit(state.copyWith(selectedAddress: event.addressData, setSelectedMessageToNull: true));
      add(GetMessagesEvent(addressData: event.addressData));
    });

    on<DeleteAddressEvent>((DeleteAddressEvent event, Emitter<DataState> emit) async {
      try {
        List<AddressData> addresses =
            state.addressList.where((a) => a.authenticatedUser.account.id != event.addressData.authenticatedUser.account.id).toList();
        await event.addressData.authenticatedUser.delete();
        emit(state.copyWith(
          addressList: addresses,
          setSelectedAddressToNull:
              state.selectedAddress != null && state.selectedAddress!.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id,
        ));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<GetMessagesEvent>((GetMessagesEvent event, Emitter<DataState> emit) async {
      try {
        final messages = await event.addressData.authenticatedUser.messagesAt(1);
        final updatesMessagesMap = {...state.accountIdToAddressesMap};
        messages.isNotEmpty ? updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages : null;
        if (state.selectedMessage != null) {
          Message? selectedMessage = messages.where((m) => m.id == state.selectedMessage!.id).firstOrNull;
          if (selectedMessage != null) {
            emit(state.copyWith(selectedMessage: selectedMessage, accountIdToAddressesMap: updatesMessagesMap));
            return;
          }
        }
        emit(state.copyWith(accountIdToAddressesMap: updatesMessagesMap));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ToggleMessageReadUnread>((ToggleMessageReadUnread event, Emitter<DataState> emit) async {
      try {
        if (event.message.seen) {
          await event.addressData.authenticatedUser.unreadMessage(event.message.id);
        } else {
          await event.addressData.authenticatedUser.readMessage(event.message.id);
        }
        add(GetMessagesEvent(addressData: event.addressData));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<SelectMessageEvent>((SelectMessageEvent event, Emitter<DataState> emit) async {
      try {
        if (state.selectedMessage?.id == event.message.id) {
          return;
        }
        await event.addressData.authenticatedUser.readMessage(event.message.id);
        emit(state.copyWith(selectedMessage: event.message));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<DeleteMessageEvent>((DeleteMessageEvent event, Emitter<DataState> emit) async {
      try {
        List<Message> messages =
            (state.accountIdToAddressesMap[event.addressData.authenticatedUser.account.id] ?? []).where((m) => m.id != event.message.id).toList();
        await event.addressData.authenticatedUser.deleteMessage(event.message.id);
        final updatesMessagesMap = {...state.accountIdToAddressesMap};
        updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages;
        bool isSelectedMessageDeleted = state.selectedMessage != null && state.selectedMessage!.id == event.message.id;
        emit(state.copyWith(setSelectedAddressToNull: isSelectedMessageDeleted, accountIdToAddressesMap: updatesMessagesMap));
        add(GetMessagesEvent(addressData: event.addressData));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ImportAddresses>((ImportAddresses event, Emitter<DataState> emit) async {
      try {
        List<AddressData> loggedInAddresses = [];
        Map<String, List<Message>> accountIdToAddressesMap = {};
        for (var address in event.addresses) {
          AuthenticatedUser? user = await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
          if (user == null) {
            loggedInAddresses.add(address.copyWith(isActive: false));
          } else {
            final messages = await user.messagesAt(1);
            messages.isNotEmpty ? accountIdToAddressesMap[user.account.id] = messages : null;
            address.copyWith(authenticatedUser: user);
          }
          loggedInAddresses.add(user != null ? address.copyWith(authenticatedUser: user) : address.copyWith(isActive: false));
        }
        emit(state.copyWith(
            addressList: [...state.addressList, ...loggedInAddresses],
            accountIdToAddressesMap: _mergeMaps(state.accountIdToAddressesMap, accountIdToAddressesMap)));
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  Map<String, List<Message>> _mergeMaps(Map<String, List<Message>> map1, Map<String, List<Message>> map2) {
    final result = <String, List<Message>>{};
    map1.forEach((key, value) {
      result[key] = List<Message>.from(value);
    });
    map2.forEach((key, value) {
      if (result.containsKey(key)) {
        result[key]!.addAll(value);
      } else {
        result[key] = List<Message>.from(value);
      }
    });
    return result;
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
