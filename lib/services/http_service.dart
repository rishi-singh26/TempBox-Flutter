import 'dart:convert';
import 'dart:io';

import 'package:mailtm_client/mailtm_client.dart';
import 'package:http/http.dart' as http;
import 'package:tempbox/models/message_data.dart';

class CreateAddressResponse {
  final AuthenticatedUser? authenticatedUser;
  final String? message;

  CreateAddressResponse({required this.authenticatedUser, required this.message});
}

class HttpService {
  static Future<CreateAddressResponse> createAddress(String email, String password, Domain? domain) async {
    Token? token = await _getToken('$email@${domain!.domain}', password);
    if (token != null) {
      return CreateAddressResponse(authenticatedUser: null, message: 'Address alredy exists, choose another address');
    }
    return CreateAddressResponse(authenticatedUser: await MailTm.register(username: email, password: password, domain: domain), message: null);
  }

  static Future<AuthenticatedUser?> login(String email, String password) async {
    Token? token = await _getToken(email, password);
    if (token == null) return null;
    return await _getAccount(token, password);
  }

  static Future<Token?> _getToken(String email, String password) async {
    final url = Uri.parse('https://api.mail.tm/token');

    try {
      String jsonBody = jsonEncode({"address": email, "password": password});
      final response = await http.post(url, headers: {HttpHeaders.contentTypeHeader: 'application/json'}, body: jsonBody);

      if (response.statusCode == HttpStatus.ok) {
        return Token.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  static Future<AuthenticatedUser?> _getAccount(Token token, String password) async {
    final url = Uri.parse('https://api.mail.tm/me');

    try {
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/ld+json',
        HttpHeaders.authorizationHeader: 'Bearer ${token.token}',
      });

      if (response.statusCode == HttpStatus.ok) {
        return AuthenticatedUser(account: Account.fromJson(jsonDecode(response.body)), password: password, token: token.token);
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  static Future<List<MessageData>?> getMessages(String token) async {
    final url = Uri.parse('https://api.mail.tm/messages');

    try {
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/ld+json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> decodedJson = jsonDecode(response.body);
        List<dynamic> json = decodedJson['hydra:member'] as List<dynamic>;
        List<MessageData> messages = json.map((json) => MessageData.fromJson(json)).toList();
        return messages;
      }
      return null;
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  static Future<MessageData?> getMessageFromId(String token, String messageId) async {
    final url = Uri.parse('https://api.mail.tm/messages/$messageId');

    try {
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/ld+json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      if (response.statusCode == HttpStatus.ok) {
        return MessageData.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }

  static Future<MessageSource?> getMessageSource(String token, String messageId) async {
    final url = Uri.parse('https://api.mail.tm/messages/$messageId/download');

    try {
      final response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'message/rfc822',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });

      if (response.statusCode == HttpStatus.ok) {
        return MessageSource(id: messageId, data: response.body);
      } else {
        return null;
      }
    } catch (e) {
      // print('Error: $e');
      return null;
    }
  }
}
