import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mailtm_client/mailtm_client.dart';
import 'package:tempbox/bloc/data/data_event.dart';
import 'package:tempbox/bloc/data/data_state.dart';
import 'package:tempbox/models/address_data.dart';
import 'package:tempbox/models/message_data.dart';
import 'package:tempbox/services/http_service.dart';

class DataBloc extends HydratedBloc<DataEvent, DataState> {
  DataBloc() : super(DataState.initial()) {
    on<AddAddressDataEvent>((AddAddressDataEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(addressList: [...state.addressList, event.address]));
    });

    on<LoginToAccountsEvent>((LoginToAccountsEvent event, Emitter<DataState> emit) async {
      try {
        List<AddressData> updateAddressList = [];
        Map<String, List<MessageData>> accountIdToAddressesMap = {...state.accountIdToMessagesMap};
        Map<String, MessageData> updatedMessageIdToMessageMap = {...state.messageIdToMessageMap};
        for (var address in state.addressList) {
          if (address.isAddressActive) {
            AuthenticatedUser? loggedInUser;
            try {
              loggedInUser = await HttpService.login(address.authenticatedUser.account.address, address.password);
            } catch (e) {
              debugPrint(e.toString());
            }
            if (loggedInUser == null) {
              updateAddressList.add(address);
            } else {
              final messages = await HttpService.getMessages(loggedInUser.token);
              if (messages == null) return;
              messages.isNotEmpty ? accountIdToAddressesMap[loggedInUser.account.id] = messages : null;
              updateAddressList.add(address.copyWith(authenticatedUser: loggedInUser));
              // get messageIdToMessages map for this account
              Map<String, MessageData> messagesMap = await _getMessagesWithHTMlFor(messages, loggedInUser);
              // update updatedMessageIdToMessages map with updated messages for this account
              updatedMessageIdToMessageMap.addAll(messagesMap);
            }
          } else {
            updateAddressList.add(address);
          }
        }
        emit(
          state.copyWith(
            addressList: updateAddressList,
            accountIdToMessagesMap: accountIdToAddressesMap,
            messageIdToMessageMap: updatedMessageIdToMessageMap,
            didRefreshAddressData: true,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<SelectAddressEvent>((SelectAddressEvent event, Emitter<DataState> emit) {
      if (state.selectedAddress?.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id) {
        return;
      }
      emit(state.copyWith(selectedAddress: event.addressData, setSelectedMessageToNull: true));
      event.addressData.isAddressActive ? add(GetMessagesEvent(addressData: event.addressData)) : null;
    });

    on<DeleteAddressEvent>((DeleteAddressEvent event, Emitter<DataState> emit) async {
      try {
        List<AddressData> addresses = state.addressList.where((a) => a != event.addressData).toList();
        emit(
          state.copyWith(
            addressList: addresses,
            setSelectedAddressToNull: state.selectedAddress != null && state.selectedAddress == event.addressData,
          ),
        );
        await event.addressData.authenticatedUser.delete();
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<RemoveAddressEvent>((RemoveAddressEvent event, Emitter<DataState> emit) async {
      try {
        emit(
          state.copyWith(
            addressList: state.addressList.where((a) => a != event.addressData).toList(),
            removedAddresses: [...state.removedAddresses, event.addressData],
            setSelectedAddressToNull: state.selectedAddress != null && state.selectedAddress == event.addressData,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<RestoreAddressesEvent>((RestoreAddressesEvent event, Emitter<DataState> emit) async {
      try {
        final set1 = state.removedAddresses.toSet();
        final set2 = event.addresses.toSet();
        // Symmetric difference (users unique to each list)
        final removedAddresses = set1.union(set2).difference(set1.intersection(set2));
        emit(state.copyWith(addressList: [...state.addressList, ...event.addresses], removedAddresses: removedAddresses.toList()));
        add(const LoginToAccountsEvent());
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<GetMessagesEvent>((GetMessagesEvent event, Emitter<DataState> emit) async {
      try {
        final messages = await HttpService.getMessages(event.addressData.authenticatedUser.token);
        if (messages == null) return;
        final updatesMessagesMap = {...state.accountIdToMessagesMap};
        messages.isNotEmpty ? updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages : null;
        // updated the selected message with updated data
        MessageData? selectedMessage = messages.where((m) => m.id == state.selectedMessage?.id).firstOrNull;
        emit(state.copyWith(accountIdToMessagesMap: updatesMessagesMap));
        if (selectedMessage != null) {
          add(SelectMessageEvent(message: selectedMessage, addressData: event.addressData, shouldUpdateMessage: false));
          return;
        }
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
        add(SelectMessageEvent(message: event.message, addressData: event.addressData, shouldUpdateMessage: false));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<SelectMessageEvent>((SelectMessageEvent event, Emitter<DataState> emit) async {
      try {
        // if currently selected address is same as new address, simply return
        // if (state.selectedMessage?.id == event.message.id) {
        //   return;
        // }
        // if selected address is null, simply return (edge case scenario, most likly will never happen)
        if (state.selectedAddress == null) {
          return;
        }
        // If address has been archived, do not get messages
        if (!state.selectedAddress!.isAddressActive) {
          emit(state.copyWith(selectedMessage: event.message));
          return;
        }
        if (event.shouldUpdateMessage != false) {
          await event.addressData.authenticatedUser.readMessage(event.message.id);
          emit(state.copyWith(selectedMessage: event.message));
        }
        MessageData? message = await HttpService.getMessageFromId(event.addressData.authenticatedUser.token, event.message.id);
        if (message == null) return;
        // all messages in selected address
        List<MessageData>? messages = state.accountIdToMessagesMap[state.selectedAddress!.authenticatedUser.account.id];
        final updatedAccountIdToMessgesMap = {...state.accountIdToMessagesMap};
        if (messages != null) {
          // in all messages list, update the newly fetched message
          List<MessageData> updatedMessages = messages.map((m) {
            if (m.id == message.id) return message;
            return m;
          }).toList();
          updatedAccountIdToMessgesMap[state.selectedAddress!.authenticatedUser.account.id] = updatedMessages;
        } else {
          updatedAccountIdToMessgesMap[state.selectedAddress!.authenticatedUser.account.id] = [message];
        }
        // update the messageIdToMessageMap with fresh message data
        final updatedMessageIdToMessageMap = {...state.messageIdToMessageMap};
        updatedMessageIdToMessageMap[message.id] = message;
        emit(
          state.copyWith(
            accountIdToMessagesMap: updatedAccountIdToMessgesMap,
            selectedMessage: message,
            messageIdToMessageMap: updatedMessageIdToMessageMap,
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<DeleteMessageEvent>((DeleteMessageEvent event, Emitter<DataState> emit) async {
      try {
        List<MessageData> messages = (state.accountIdToMessagesMap[event.addressData.authenticatedUser.account.id] ?? [])
            .where((m) => m.id != event.message.id)
            .toList();
        event.addressData.isAddressActive ? await event.addressData.authenticatedUser.deleteMessage(event.message.id) : null;
        final updatesMessagesMap = {...state.accountIdToMessagesMap};
        updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages;
        bool isSelectedMessageDeleted = state.selectedMessage != null && state.selectedMessage!.id == event.message.id;
        emit(state.copyWith(setSelectedMessageToNull: isSelectedMessageDeleted, accountIdToMessagesMap: updatesMessagesMap));
        event.addressData.isAddressActive ? add(GetMessagesEvent(addressData: event.addressData)) : null;
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ImportAddresses>((ImportAddresses event, Emitter<DataState> emit) async {
      try {
        List<AddressData> loggedInAddresses = [];
        Map<String, List<MessageData>> accountIdToAddressesMap = {};
        for (var address in event.addresses) {
          AuthenticatedUser? user = await HttpService.login(address.authenticatedUser.account.address, address.password);
          if (user == null) {
            loggedInAddresses.add(address.copyWith(archived: false));
          } else {
            final messages = await HttpService.getMessages(user.token);
            messages != null && messages.isNotEmpty ? accountIdToAddressesMap[user.account.id] = messages : null;
            address.copyWith(authenticatedUser: user);
          }
          loggedInAddresses.add(user != null ? address.copyWith(authenticatedUser: user) : address.copyWith(archived: false));
        }
        emit(
          state.copyWith(
            addressList: [...state.addressList, ...loggedInAddresses],
            accountIdToMessagesMap: _mergeMaps(state.accountIdToMessagesMap, accountIdToAddressesMap),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ResetStateEvent>((ResetStateEvent event, Emitter<DataState> emit) async {
      for (var address in state.addressList) {
        await address.authenticatedUser.delete();
      }
      emit(DataState.initial());
    });
  }

  Map<String, List<MessageData>> _mergeMaps(Map<String, List<MessageData>> map1, Map<String, List<MessageData>> map2) {
    final result = <String, List<MessageData>>{};
    map1.forEach((key, value) {
      result[key] = List<MessageData>.from(value);
    });
    map2.forEach((key, value) {
      if (result.containsKey(key)) {
        result[key]!.addAll(value);
      } else {
        result[key] = List<MessageData>.from(value);
      }
    });
    return result;
  }

  Future<Map<String, MessageData>> _getMessagesWithHTMlFor(List<MessageData> messages, AuthenticatedUser user) async {
    Map<String, MessageData> updatedMessageIdToMessageMap = {...state.messageIdToMessageMap};
    for (var m in messages) {
      try {
        MessageData? mes = await HttpService.getMessageFromId(user.token, m.id);
        if (mes != null) updatedMessageIdToMessageMap[mes.id] = mes;
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return updatedMessageIdToMessageMap;
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
