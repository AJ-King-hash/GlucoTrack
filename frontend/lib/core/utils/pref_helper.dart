import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper{
  static const String _tokenKey ="auth_token";
  //save token
  static Future<void>saveToken(String token)async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  //get token
  static Future<String?>getToken()async{
    final prefs = await SharedPreferences.getInstance();
     return prefs.getString(_tokenKey);

  }
  //clear token
  static Future<void>clearToken()async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_tokenKey);
  }
}