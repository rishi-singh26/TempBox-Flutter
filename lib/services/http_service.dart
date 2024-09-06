import 'dart:convert';
import 'dart:io';

import 'package:mailtm_client/mailtm_client.dart';
import 'package:http/http.dart' as http;

class HttpService {
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
      final response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/ld+json',
          HttpHeaders.authorizationHeader: 'Bearer ${token.token}',
        },
      );

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
}
