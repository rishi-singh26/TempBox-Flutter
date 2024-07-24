import 'dart:convert';
import 'dart:io';

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
        Map<String, List<Message>> accountIdToAddressesMap = {...state.accountIdToAddressesMap};
        for (var address in state.addressList) {
          if (address.isActive) {
            AuthenticatedUser? loggedInUser;
            try {
              loggedInUser = await MailTm.login(address: address.authenticatedUser.account.address, password: address.password);
            } catch (e) {
              debugPrint(e.toString());
            }
            if (loggedInUser == null) {
              updateAddressList.add(address.copyWith(isActive: false));
            } else {
              final messages = await loggedInUser.messagesAt(1);
              messages.isNotEmpty ? accountIdToAddressesMap[loggedInUser.account.id] = messages : null;
              updateAddressList.add(address);
            }
          } else {
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
      event.addressData.isActive ? add(GetMessagesEvent(addressData: event.addressData)) : null;
    });

    on<ResetSelectedAddressEvent>((ResetSelectedAddressEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(setSelectedAddressToNull: true));
    });

    on<DeleteAddressEvent>((DeleteAddressEvent event, Emitter<DataState> emit) async {
      try {
        List<AddressData> addresses =
            state.addressList.where((a) => a.authenticatedUser.account.id != event.addressData.authenticatedUser.account.id).toList();
        event.addressData.isActive ? await event.addressData.authenticatedUser.delete() : null;
        emit(state.copyWith(
          addressList: addresses,
          setSelectedAddressToNull:
              state.selectedAddress != null && state.selectedAddress!.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id,
        ));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ArchiveAddressEvent>((ArchiveAddressEvent event, Emitter<DataState> emit) async {
      try {
        await event.addressData.authenticatedUser.delete();
        List<AddressData> addresses = state.addressList.map((a) {
          if (a.authenticatedUser.account.id == event.addressData.authenticatedUser.account.id) {
            return a.copyWith(isActive: false);
          }
          return a;
        }).toList();
        emit(state.copyWith(addressList: addresses));
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<GetMessagesEvent>((GetMessagesEvent event, Emitter<DataState> emit) async {
      try {
        final messages = await event.addressData.authenticatedUser.messagesAt(1);
        final updatesMessagesMap = {...state.accountIdToAddressesMap};
        messages.isNotEmpty ? updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages : null;
        // updated the selected message with updated data
        Message? selectedMessage = messages.where((m) => m.id == state.selectedMessage?.id).firstOrNull;
        if (selectedMessage != null) {
          add(SelectMessageEvent(message: selectedMessage, addressData: event.addressData, markAsRead: false));
          return;
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
        add(SelectMessageEvent(message: event.message, addressData: event.addressData, markAsRead: false));
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
        if (!state.selectedAddress!.isActive) {
          emit(state.copyWith(selectedMessage: event.message));
          return;
        }
        event.markAsRead != false ? await event.addressData.authenticatedUser.readMessage(event.message.id) : null;
        Message? message = await _fetchData(state.selectedAddress!.authenticatedUser, event.message);
        if (message != null) {
          // all messages in selected address
          List<Message>? messages = state.accountIdToAddressesMap[state.selectedAddress!.authenticatedUser.account.id];
          final updatedAccountIdToAddressesMap = {...state.accountIdToAddressesMap};
          if (messages != null) {
            // in all messages list, update the newly fetched message
            List<Message> updatedMessages = messages.map((m) {
              if (m.id == message.id) return message;
              return m;
            }).toList();
            updatedAccountIdToAddressesMap[state.selectedAddress!.authenticatedUser.account.id] = updatedMessages;
          } else {
            updatedAccountIdToAddressesMap[state.selectedAddress!.authenticatedUser.account.id] = [message];
          }
          emit(state.copyWith(accountIdToAddressesMap: updatedAccountIdToAddressesMap, selectedMessage: message));
        } else {
          emit(state.copyWith(selectedMessage: event.message));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    on<ResetSelectedMessageEvent>((ResetSelectedMessageEvent event, Emitter<DataState> emit) {
      emit(state.copyWith(setSelectedMessageToNull: true));
    });

    on<DeleteMessageEvent>((DeleteMessageEvent event, Emitter<DataState> emit) async {
      try {
        List<Message> messages =
            (state.accountIdToAddressesMap[event.addressData.authenticatedUser.account.id] ?? []).where((m) => m.id != event.message.id).toList();
        event.addressData.isActive ? await event.addressData.authenticatedUser.deleteMessage(event.message.id) : null;
        final updatesMessagesMap = {...state.accountIdToAddressesMap};
        updatesMessagesMap[event.addressData.authenticatedUser.account.id] = messages;
        bool isSelectedMessageDeleted = state.selectedMessage != null && state.selectedMessage!.id == event.message.id;
        emit(state.copyWith(setSelectedMessageToNull: isSelectedMessageDeleted, accountIdToAddressesMap: updatesMessagesMap));
        event.addressData.isActive ? add(GetMessagesEvent(addressData: event.addressData)) : null;
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

  Future<Message?> _fetchData(AuthenticatedUser user, Message message) async {
    final url = Uri.parse('https://api.mail.tm/messages/${message.id}');
    final client = HttpClient();

    try {
      final request = await client.getUrl(url);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/ld+json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${user.token}');

      final response = await request.close();

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonData = json.decode(responseBody);
        return Message.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    } finally {
      client.close();
    }
  }

  @override
  DataState fromJson(Map<String, dynamic> json) {
    return DataState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(DataState state) => state.toJson();
}
