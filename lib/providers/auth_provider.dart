import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/exceptions/http_exception.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }
  String get userId => _userId;

  Future<void> authenticate(
      String email, String password, String method) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$method?key=AIzaSyBV10jTe16QwDhO1HCNMs7bsgcFkkYyqIg';
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token' : _token,
        'userId' : _userId,
        'expiryDate' : _expiryDate.toIso8601String(),
      });
      print(userId);
      print('authenticate');
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userData'));
    if(!prefs.containsKey('userData')){
      print('Containts Key');
      return false;
    }
    final extractedUserData= jsonDecode(prefs.getString('userData')) as Map<String,dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())) {
      print('expiryDate');
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }
  Future<void> logout() async {
    _token=null;
    _userId = null;
    _expiryDate = null;
    if(_authTimer != null) {
      _authTimer.cancel();
    }
    notifyListeners();
    final prefs =await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if(_authTimer != null) {
      _authTimer.cancel();
    }
    int dif = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds:dif ),logout);
  }

}
